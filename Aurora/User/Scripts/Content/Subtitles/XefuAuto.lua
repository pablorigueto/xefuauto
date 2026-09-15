-- XefuAuto - troca o xefu automaticamente conforme o jogo selecionado.
-- Gerado automaticamente por gerar_auto.py. Nao edite a mao.
-- Jogos mapeados: 961

local COMPAT = "Hddx:\\Compatibility\\"
local BACKUP = "Hddx:\\Compatibility\\XefuBackup\\"
local ESTADO = COMPAT .. "xefu_auto.txt"
local DESLIGADO = COMPAT .. "xefu_auto_off.txt"

-- TODOS os slots que o emulador pode carregar. Precisa cobrir os 12:
-- se um slot ficar de fora e o emulador escolher justo ele, o jogo roda
-- com a versao errada (foi o caso dos xefu2021*).
local SLOTS = {"xefu.xex", "xefu2.xex", "xefu3.xex", "xefu5.xex",
               "xefu1_1.xex", "xefu6.xex", "xefu7.xex", "xefu7b.xex",
               "xefu2019.xex", "xefu2021a.xex", "xefu2021b.xex",
               "xefu2021c.xex"}
local SLOTS_TITLE = {"xefutitle.xex", "xefutitle5.xex", "xefutitle6.xex",
                     "xefutitle7.xex", "xefutitle7b.xex",
                     "xefutitle2019.xex", "xefutitle2021.xex"}

local XEFUS = {"xefu.xex","xefu1_1.xex","xefu2.xex","xefu2019.xex","xefu2021b.xex","xefu2021c.xex","xefu3.xex","xefu5.xex","xefu6.xex","xefu7.xex","xefu7b.xex"}
local TITLES = {"xefutitle.xex","xefutitle.xex","xefutitle.xex","xefutitle2019.xex","xefutitle2021.xex","xefutitle2021.xex","xefutitle.xex","xefutitle5.xex","xefutitle6.xex","xefutitle7.xex","xefutitle7b.xex"}

-- TitleId -> indice em XEFUS (casamento exato, tem prioridade)
local MAPA = {
	[0x41430001]=11,[0x41430002]=8,[0x41430004]=10,[0x41430005]=1,[0x41430006]=10,[0x41430007]=7,[0x4143000A]=1,[0x4143000B]=1,[0x4143000C]=1,[0x4143000D]=10,
	[0x4143000E]=1,[0x4143000F]=10,[0x41430010]=1,[0x41430014]=10,[0x41430016]=1,[0x41430017]=10,[0x41430018]=7,[0x41430019]=10,[0x4143001A]=10,[0x4143001B]=10,
	[0x4143001C]=7,[0x4143001D]=9,[0x4143001F]=10,[0x41440002]=1,[0x41480002]=10,[0x41500001]=8,[0x41510001]=9,[0x41510002]=7,[0x41540001]=6,[0x41540002]=10,
	[0x41540003]=10,[0x41540004]=10,[0x41560001]=10,[0x41560002]=1,[0x41560003]=10,[0x41560004]=10,[0x41560005]=10,[0x41560006]=7,[0x41560007]=10,[0x41560008]=8,
	[0x41560009]=10,[0x4156000B]=1,[0x4156000D]=8,[0x4156000E]=8,[0x41560010]=10,[0x41560014]=7,[0x41560017]=1,[0x41560018]=1,[0x41560019]=1,[0x4156001A]=10,
	[0x4156001B]=10,[0x4156001E]=10,[0x4156001F]=1,[0x41560020]=7,[0x41560022]=7,[0x41560026]=10,[0x4156002A]=1,[0x4156002B]=10,[0x4156002D]=10,[0x41560030]=1,
	[0x41560035]=8,[0x41560037]=9,[0x41560038]=8,[0x4156003A]=8,[0x4156003B]=10,[0x4156003C]=1,[0x4156003D]=6,[0x4156003E]=1,[0x4156003F]=1,[0x41560041]=1,
	[0x41560042]=1,[0x41560045]=10,[0x41560046]=10,[0x41560047]=10,[0x41560048]=10,[0x41560049]=1,[0x4156004B]=10,[0x4156004D]=1,[0x4156004E]=10,[0x4156004F]=10,
	[0x41560050]=1,[0x41560051]=10,[0x41560052]=10,[0x41560054]=10,[0x41560055]=1,[0x41560057]=10,[0x41560058]=8,[0x4156005B]=10,[0x4156005C]=10,[0x4156005D]=10,
	[0x4156005E]=10,[0x41570001]=10,[0x41590002]=1,[0x41590004]=7,[0x42410001]=8,[0x42410002]=10,[0x42420002]=10,[0x424D0002]=10,[0x424D0003]=10,[0x42520001]=10,
	[0x42530001]=10,[0x42530004]=10,[0x42530005]=10,[0x42530006]=10,[0x42530007]=8,[0x42530009]=10,[0x4253000A]=6,[0x4253000B]=10,[0x4253000C]=1,[0x4253000F]=1,
	[0x42530011]=1,[0x42530012]=10,[0x42560001]=10,[0x42560002]=10,[0x42560003]=10,[0x42560004]=10,[0x42570001]=10,[0x43430001]=1,[0x43430003]=10,[0x43430005]=2,
	[0x43430007]=10,[0x43430008]=10,[0x4343000A]=7,[0x4343000B]=10,[0x4343000C]=10,[0x4343000E]=10,[0x4343000F]=10,[0x43430011]=1,[0x43430013]=10,[0x43430014]=10,
	[0x43430015]=10,[0x43430016]=1,[0x43430018]=6,[0x43430019]=6,[0x434B0001]=10,[0x434D0001]=6,[0x434D0002]=1,[0x434D0003]=1,[0x434D0004]=10,[0x434D0006]=10,
	[0x434D0008]=10,[0x434D000C]=10,[0x434D000D]=10,[0x434D000F]=10,[0x434D0010]=1,[0x434D0011]=10,[0x434D0024]=7,[0x434D0029]=1,[0x434D002A]=10,[0x434D002B]=10,
	[0x434D003F]=10,[0x434D0046]=10,[0x434D0047]=4,[0x434D004E]=10,[0x434D0050]=10,[0x434D0052]=1,[0x434D0054]=10,[0x434D005A]=10,[0x434D005B]=10,[0x43560001]=8,
	[0x43560005]=1,[0x43560006]=7,[0x43560007]=10,[0x43560008]=10,[0x43560009]=7,[0x4356000A]=1,[0x4356000D]=10,[0x4356000E]=1,[0x43560010]=10,[0x43560011]=10,
	[0x44430002]=10,[0x44430003]=10,[0x44430004]=10,[0x44580001]=10,[0x45410001]=10,[0x45410002]=10,[0x45410003]=10,[0x45410004]=10,[0x45410005]=10,[0x45410007]=1,
	[0x45410009]=10,[0x4541000A]=10,[0x4541000B]=6,[0x4541000E]=10,[0x45410010]=10,[0x45410011]=6,[0x45410012]=7,[0x45410013]=1,[0x45410015]=10,[0x45410017]=1,
	[0x45410019]=10,[0x4541001A]=1,[0x4541001B]=10,[0x4541001C]=10,[0x4541001E]=10,[0x45410021]=10,[0x45410026]=1,[0x45410027]=10,[0x45410028]=10,[0x45410029]=1,
	[0x4541002C]=8,[0x4541002D]=9,[0x4541002E]=10,[0x4541002F]=10,[0x45410030]=1,[0x45410031]=10,[0x45410032]=10,[0x45410035]=10,[0x45410036]=10,[0x45410037]=1,
	[0x45410038]=1,[0x45410039]=10,[0x4541003A]=10,[0x4541003B]=1,[0x4541003C]=7,[0x4541003D]=10,[0x4541003E]=1,[0x4541003F]=1,[0x45410042]=10,[0x45410043]=10,
	[0x45410044]=10,[0x45410045]=9,[0x45410047]=9,[0x45410048]=10,[0x4541004A]=1,[0x4541004B]=1,[0x4541004C]=10,[0x4541004D]=10,[0x4541004E]=10,[0x4541004F]=10,
	[0x45410050]=10,[0x45410051]=10,[0x45410052]=10,[0x45410053]=10,[0x45410054]=10,[0x45410055]=1,[0x45410056]=10,[0x45410057]=10,[0x45410058]=10,[0x4541005A]=1,
	[0x4541005B]=9,[0x4541005C]=7,[0x4541005D]=10,[0x4541005E]=1,[0x4541005F]=10,[0x45410060]=10,[0x45410061]=10,[0x45410062]=6,[0x45410063]=1,[0x45410065]=10,
	[0x45410066]=6,[0x4541006D]=10,[0x4541006F]=1,[0x45410070]=10,[0x45410071]=1,[0x45410072]=1,[0x45410074]=10,[0x45410075]=10,[0x45410076]=10,[0x45410077]=1,
	[0x45410078]=10,[0x4541007A]=10,[0x4541007B]=3,[0x4541007C]=10,[0x4541007D]=10,[0x4541007E]=10,[0x45410080]=9,[0x45410082]=10,[0x45410083]=7,[0x45410085]=10,
	[0x45410086]=9,[0x45410087]=10,[0x4541008B]=10,[0x4541008D]=10,[0x4541008E]=10,[0x45410090]=10,[0x45410091]=8,[0x45410093]=10,[0x45410094]=10,[0x45410095]=9,
	[0x4541009C]=8,[0x4541009E]=10,[0x4541009F]=10,[0x454100A0]=10,[0x454100A1]=9,[0x454100A2]=10,[0x454100A3]=10,[0x454100A4]=10,[0x454100A5]=10,[0x454100A6]=10,
	[0x454100AB]=10,[0x454100AC]=10,[0x4541023B]=10,[0x45410389]=1,[0x4541038A]=9,[0x4541038B]=10,[0x45430001]=1,[0x45430002]=1,[0x45430004]=10,[0x45460001]=8,
	[0x454C0001]=1,[0x454D0002]=7,[0x454D0004]=10,[0x454D0005]=10,[0x454D0007]=10,[0x454D0009]=7,[0x454D000A]=10,[0x454D000D]=10,[0x454D0016]=7,[0x454D0017]=6,
	[0x454D001B]=10,[0x454D001D]=10,[0x454D001E]=10,[0x454D001F]=10,[0x454D0020]=10,[0x45530001]=9,[0x45530004]=1,[0x45530005]=10,[0x45530006]=11,[0x45530008]=1,
	[0x45530009]=6,[0x4553000A]=6,[0x4553000D]=10,[0x4553000E]=10,[0x45530011]=10,[0x45530012]=1,[0x45530013]=1,[0x45530014]=2,[0x45530016]=10,[0x45530018]=10,
	[0x45530019]=10,[0x4553001A]=10,[0x4553001D]=7,[0x46490002]=1,[0x464C0002]=6,[0x46530001]=1,[0x46530002]=10,[0x46530003]=10,[0x46530004]=10,[0x47560001]=9,
	[0x47560004]=10,[0x47560009]=10,[0x4756000A]=10,[0x4756000B]=10,[0x48450001]=10,[0x48450004]=10,[0x48450005]=10,[0x48500001]=10,[0x48500005]=10,[0x48550001]=11,
	[0x49410001]=10,[0x49460001]=8,[0x49470001]=10,[0x49470004]=10,[0x49470005]=10,[0x49470006]=1,[0x49470007]=10,[0x49470009]=10,[0x4947000B]=10,[0x4947000D]=8,
	[0x4947000E]=10,[0x4947000F]=10,[0x49470010]=1,[0x49470011]=10,[0x49470012]=7,[0x49470013]=10,[0x49470015]=10,[0x49470016]=10,[0x49470018]=10,[0x4947001B]=10,
	[0x4947001C]=1,[0x4947001F]=10,[0x49470022]=10,[0x49470024]=10,[0x49470025]=10,[0x49470026]=1,[0x49470027]=10,[0x49470028]=10,[0x49470029]=1,[0x4947002B]=10,
	[0x4947002C]=10,[0x49470034]=10,[0x49470038]=10,[0x49470039]=10,[0x4947003B]=10,[0x4947003C]=10,[0x4947003D]=9,[0x4947003E]=10,[0x49470072]=10,[0x49470073]=10,
	[0x49470074]=10,[0x49470075]=1,[0x49470079]=1,[0x4947007A]=10,[0x4947007B]=8,[0x4947007C]=10,[0x4947007D]=10,[0x4947007F]=10,[0x494C0002]=10,[0x494C0006]=5,
	[0x494F0003]=10,[0x494F0008]=7,[0x49500006]=10,[0x49500008]=10,[0x4950000A]=1,[0x49580001]=10,[0x4A410002]=10,[0x4A410004]=1,[0x4A410005]=1,[0x4A410007]=10,
	[0x4A570002]=1,[0x4A570003]=10,[0x4A570009]=7,[0x4A57000A]=10,[0x4B410001]=10,[0x4B420001]=10,[0x4B420002]=1,[0x4B420004]=1,[0x4B420005]=1,[0x4B420006]=10,
	[0x4B420007]=10,[0x4B490002]=10,[0x4B4B0002]=10,[0x4B4B0003]=10,[0x4B4E0001]=10,[0x4B4E0002]=1,[0x4B4E0003]=10,[0x4B4E0004]=9,[0x4B4E0005]=1,[0x4B4E0007]=10,
	[0x4B4E0008]=10,[0x4B4E000B]=10,[0x4B4E000E]=10,[0x4B4E0010]=10,[0x4B4E0011]=10,[0x4B4E0012]=10,[0x4B4E0013]=1,[0x4B4E0019]=10,[0x4B4E001A]=10,[0x4B4E001B]=1,
	[0x4B4E001C]=10,[0x4B4E001E]=10,[0x4B4E001F]=7,[0x4B4E0020]=9,[0x4B4E0021]=10,[0x4B4E0022]=6,[0x4B4E0023]=10,[0x4B4E0024]=9,[0x4B4E0025]=10,[0x4B4E0027]=10,
	[0x4B4E0029]=10,[0x4B4E002A]=10,[0x4B4E002C]=1,[0x4B4E002D]=10,[0x4B4E002E]=10,[0x4B4E002F]=7,[0x4B4E0030]=1,[0x4B4E0037]=10,[0x4B4E0038]=8,[0x4B4F0001]=10,
	[0x4B4F0002]=6,[0x4B4F0003]=10,[0x4B4F0004]=8,[0x4B4F0005]=1,[0x4B4F0006]=1,[0x4B4F0007]=10,[0x4B4F0008]=8,[0x4B550001]=9,[0x4C410001]=6,[0x4C410002]=10,
	[0x4C410003]=1,[0x4C410004]=1,[0x4C410005]=10,[0x4C410006]=10,[0x4C410007]=10,[0x4C410009]=10,[0x4C41000B]=1,[0x4C41000D]=10,[0x4C41000F]=7,[0x4C410011]=7,
	[0x4C410013]=10,[0x4C410014]=1,[0x4C410015]=10,[0x4C410017]=1,[0x4C410019]=10,[0x4C41001A]=7,[0x4C41001F]=8,[0x4C410022]=9,[0x4C530002]=10,[0x4D440003]=10,
	[0x4D440004]=1,[0x4D450001]=10,[0x4D490003]=10,[0x4D490006]=10,[0x4D490008]=10,[0x4D49000B]=10,[0x4D49000D]=1,[0x4D4A0001]=6,[0x4D4A0002]=10,[0x4D4A0003]=10,
	[0x4D4A0008]=10,[0x4D4A0009]=10,[0x4D4A000B]=1,[0x4D4A000C]=9,[0x4D4A000D]=10,[0x4D4A000F]=10,[0x4D4A0011]=1,[0x4D4A0012]=9,[0x4D4A0013]=10,[0x4D4A0014]=6,
	[0x4D4A0017]=1,[0x4D4D0001]=10,[0x4D500001]=10,[0x4D530001]=10,[0x4D530002]=10,[0x4D530003]=10,[0x4D530004]=1,[0x4D530005]=1,[0x4D530006]=11,[0x4D530008]=10,
	[0x4D53000A]=10,[0x4D53000B]=10,[0x4D53000C]=6,[0x4D53000D]=7,[0x4D53000F]=7,[0x4D530010]=6,[0x4D530011]=10,[0x4D530013]=10,[0x4D530015]=1,[0x4D530017]=7,
	[0x4D53001E]=1,[0x4D530021]=1,[0x4D530023]=8,[0x4D530027]=8,[0x4D530028]=10,[0x4D53002A]=10,[0x4D53002D]=3,[0x4D53002E]=8,[0x4D53002F]=7,[0x4D530031]=10,
	[0x4D530032]=9,[0x4D530034]=1,[0x4D530035]=10,[0x4D530036]=8,[0x4D530039]=10,[0x4D53003D]=10,[0x4D530040]=8,[0x4D530041]=7,[0x4D530045]=10,[0x4D530046]=10,
	[0x4D53004A]=10,[0x4D53004B]=10,[0x4D53004D]=9,[0x4D53004E]=10,[0x4D530050]=10,[0x4D530051]=9,[0x4D530053]=7,[0x4D530057]=1,[0x4D53005D]=8,[0x4D530064]=2,
	[0x4D530065]=10,[0x4D530066]=8,[0x4D53006B]=10,[0x4D53006D]=1,[0x4D53006E]=7,[0x4D530084]=1,[0x4D5300D1]=7,[0x4D5300D2]=6,[0x4D5300D3]=10,[0x4D5300D4]=10,
	[0x4D5380CD]=1,[0x4D570001]=1,[0x4D570002]=10,[0x4D570003]=10,[0x4D570004]=10,[0x4D570005]=10,[0x4D570006]=10,[0x4D570007]=7,[0x4D570008]=10,[0x4D570009]=7,
	[0x4D57000A]=1,[0x4D57000B]=1,[0x4D57000C]=10,[0x4D57000D]=1,[0x4D57000E]=6,[0x4D57000F]=1,[0x4D570010]=10,[0x4D570011]=7,[0x4D570012]=10,[0x4D570014]=1,
	[0x4D570015]=7,[0x4D570016]=10,[0x4D570017]=10,[0x4D570018]=10,[0x4D570019]=8,[0x4D57001A]=10,[0x4D57001B]=1,[0x4D57001C]=10,[0x4D57001D]=10,[0x4D570020]=10,
	[0x4D570021]=10,[0x4D570022]=7,[0x4D570023]=8,[0x4D570024]=10,[0x4D570025]=10,[0x4D570026]=10,[0x4D570029]=10,[0x4D57002C]=10,[0x4D57002E]=10,[0x4D570033]=7,
	[0x4D570034]=9,[0x4D570037]=8,[0x4D570038]=10,[0x4D580001]=7,[0x4E4B0001]=10,[0x4E4C0002]=6,[0x4E4D0001]=7,[0x4E4D0003]=10,[0x4E4D0005]=8,[0x4E4D0006]=10,
	[0x4E4D0007]=1,[0x4E4D0008]=10,[0x4E4D0009]=11,[0x4E4D000B]=7,[0x4E4D000C]=7,[0x4E4D000F]=8,[0x4E4D0013]=1,[0x4E4D0015]=10,[0x4E4D0016]=8,[0x4E4D0017]=10,
	[0x4F580001]=10,[0x4F580002]=10,[0x4F580004]=10,[0x50430001]=10,[0x504C0001]=1,[0x504C0002]=10,[0x504C0004]=10,[0x504C0005]=10,[0x504C0006]=10,[0x52410003]=10,
	[0x52440001]=1,[0x53410002]=10,[0x53410003]=10,[0x53430001]=1,[0x53430003]=1,[0x53430005]=7,[0x53430006]=11,[0x5343000A]=6,[0x5343000C]=6,[0x5343000E]=7,
	[0x5343000F]=1,[0x534300F7]=10,[0x534300F9]=10,[0x534300FA]=6,[0x534300FB]=10,[0x534300FF]=10,[0x53430100]=10,[0x53450002]=10,[0x53450003]=10,[0x53450004]=10,
	[0x53450006]=11,[0x53450007]=10,[0x53450008]=1,[0x5345000A]=10,[0x5345000B]=10,[0x5345000E]=1,[0x5345000F]=10,[0x53450010]=10,[0x53450011]=9,[0x53450013]=10,
	[0x53450014]=1,[0x53450017]=10,[0x53450018]=10,[0x5345001A]=7,[0x5345001D]=10,[0x53450021]=10,[0x53450023]=10,[0x53450024]=9,[0x53450025]=10,[0x53450026]=10,
	[0x53450027]=1,[0x53450028]=7,[0x53450029]=10,[0x5345002A]=10,[0x5345002B]=1,[0x53450030]=10,[0x53450031]=10,[0x53450032]=10,[0x53450033]=10,[0x53450035]=1,
	[0x53450036]=9,[0x53450037]=10,[0x53450038]=1,[0x5345003C]=1,[0x53450081]=10,[0x53450086]=1,[0x53450087]=10,[0x53450088]=10,[0x5345008B]=10,[0x534E0002]=10,
	[0x534E0003]=10,[0x534E0004]=10,[0x534E0005]=10,[0x534E0006]=10,[0x534E0007]=10,[0x534E0008]=10,[0x534E000A]=10,[0x53500001]=1,[0x53530003]=1,[0x53530006]=9,
	[0x53530007]=1,[0x53538003]=9,[0x53540001]=10,[0x53550001]=7,[0x53550002]=7,[0x53550003]=7,[0x53550004]=7,[0x53550005]=7,[0x53550006]=1,[0x53550007]=10,
	[0x53550008]=10,[0x53550009]=8,[0x54430001]=10,[0x54430003]=7,[0x54430004]=7,[0x54430006]=7,[0x54430007]=3,[0x54430009]=10,[0x5443000A]=8,[0x5443000D]=7,
	[0x5443000E]=1,[0x54440006]=8,[0x544B0004]=8,[0x544D0001]=10,[0x544D0002]=1,[0x544D0003]=7,[0x544D0004]=10,[0x544D0005]=10,[0x544D0007]=10,[0x544D0008]=10,
	[0x544D000A]=10,[0x544D000B]=10,[0x544D000D]=10,[0x544D000F]=1,[0x544D0010]=1,[0x544D0011]=10,[0x544D0012]=10,[0x544D0013]=10,[0x54510001]=10,[0x54510002]=10,
	[0x54510003]=10,[0x54510004]=10,[0x54510005]=1,[0x54510007]=1,[0x54510008]=9,[0x54510009]=10,[0x5451000A]=1,[0x5451000B]=8,[0x5451000C]=1,[0x5451000D]=1,
	[0x5451000E]=10,[0x54510010]=11,[0x54510016]=9,[0x54510018]=7,[0x5451001A]=1,[0x5451001C]=10,[0x5451001D]=10,[0x5451001E]=10,[0x5451001F]=1,[0x54510020]=1,
	[0x54510021]=8,[0x54510022]=10,[0x54510023]=1,[0x54510024]=10,[0x54510025]=11,[0x54510026]=8,[0x54510027]=8,[0x54510028]=8,[0x54510089]=9,[0x5451008B]=10,
	[0x545100ED]=7,[0x545100EF]=10,[0x545100F2]=10,[0x545100F4]=10,[0x545100F5]=10,[0x545100F6]=7,[0x545100F7]=10,[0x545100F8]=10,[0x545100FA]=9,[0x54510105]=10,
	[0x54510106]=10,[0x54510109]=10,[0x54530002]=10,[0x54540001]=7,[0x54540003]=1,[0x54540004]=8,[0x54540005]=1,[0x54540006]=7,[0x54540008]=10,[0x5454000A]=7,
	[0x5454000B]=10,[0x5454000C]=1,[0x5454000E]=1,[0x5454000F]=1,[0x54540010]=10,[0x54540011]=1,[0x54540012]=1,[0x54540014]=1,[0x54540015]=10,[0x54540016]=10,
	[0x54540017]=1,[0x54540018]=10,[0x54540019]=1,[0x5454001A]=1,[0x54540073]=1,[0x54540076]=8,[0x54540077]=1,[0x54540079]=10,[0x5454007A]=10,[0x5454007B]=10,
	[0x5454007D]=10,[0x5454007E]=10,[0x54540081]=6,[0x54540082]=1,[0x54540083]=10,[0x54540086]=1,[0x54540087]=10,[0x54540088]=10,[0x54540089]=8,[0x5454008A]=6,
	[0x5454008C]=10,[0x5454008D]=10,[0x5454008F]=8,[0x54540090]=10,[0x54540091]=10,[0x54540092]=10,[0x54540093]=1,[0x5454009B]=10,[0x5454009C]=10,[0x545400A3]=1,
	[0x545400A4]=1,[0x545400A5]=1,[0x545400A9]=7,[0x545400AB]=10,[0x545400AD]=10,[0x545400AE]=10,[0x545400AF]=10,[0x545400B0]=8,[0x545400B1]=10,[0x55530001]=10,
	[0x55530002]=10,[0x55530003]=1,[0x55530004]=1,[0x55530005]=3,[0x55530006]=3,[0x55530007]=8,[0x55530008]=9,[0x55530009]=1,[0x5553000B]=6,[0x5553000C]=3,
	[0x55530011]=10,[0x55530012]=10,[0x55530013]=3,[0x55530014]=11,[0x55530015]=10,[0x55530016]=1,[0x55530018]=10,[0x55530019]=3,[0x5553001C]=10,[0x5553001D]=1,
	[0x55530020]=1,[0x55530034]=1,[0x55530036]=10,[0x55530037]=3,[0x55530039]=6,[0x5553003A]=10,[0x5553003B]=10,[0x5553003D]=1,[0x5553003F]=10,[0x55530040]=1,
	[0x55530041]=7,[0x55530043]=10,[0x55530048]=8,[0x55530049]=10,[0x5553004A]=10,[0x5553004B]=10,[0x5553004C]=10,[0x5553004D]=3,[0x55530054]=10,[0x55530056]=10,
	[0x55530057]=10,[0x55530058]=10,[0x5553005A]=6,[0x5553005C]=1,[0x5553005E]=9,[0x5553005F]=10,[0x55530060]=10,[0x55530061]=9,[0x5553803E]=1,[0x56430001]=8,
	[0x564E0004]=10,[0x56550003]=10,[0x56550004]=10,[0x56550005]=1,[0x56550007]=10,[0x56550008]=1,[0x56550009]=6,[0x5655000A]=1,[0x5655000D]=1,[0x5655000E]=10,
	[0x5655000F]=1,[0x56550011]=1,[0x56550013]=10,[0x56550014]=1,[0x56550015]=1,[0x56550017]=10,[0x56550018]=10,[0x56550019]=10,[0x5655001A]=10,[0x5655001F]=8,
	[0x56550021]=1,[0x56550022]=1,[0x56550027]=10,[0x56550028]=3,[0x56550029]=10,[0x5655002A]=1,[0x5655002D]=10,[0x5655002F]=10,[0x56550030]=1,[0x56550031]=8,
	[0x56550034]=1,[0x56550036]=1,[0x56550037]=10,[0x56550039]=1,[0x5655003F]=9,[0x56550042]=6,[0x56550043]=10,[0x56550048]=10,[0x56550049]=10,[0x5655004A]=8,
	[0x5655004B]=10,[0x5655801B]=10,[0x56560001]=10,[0x56560003]=1,[0x56560008]=1,[0x5656000A]=1,[0x5656000D]=1,[0x56560010]=1,[0x56560025]=10,[0x56560029]=10,
	[0x57450001]=10,[0x57450005]=10,[0x57520001]=9,[0x58490004]=6,[0x58490005]=10,[0x58490007]=1,[0x584C8014]=7,[0x584D0003]=6,[0x58500004]=10,[0x5A440001]=10,
	[0x5A440004]=10
}

-- nome normalizado -> indice em XEFUS (940 jogos)
-- A lista da comunidade so tem NOME para a maioria dos jogos, entao esta
-- tabela e o que faz o pacote cobrir a lista inteira em qualquer console.
local POR_NOME = {
	["007nightfire"]=10,["100bulletsproto"]=10,["187rideordie"]=10,["2002fifaworldcup"]=6,["25tolife"]=10,["4x4evo2"]=10,
	["50centbulletproof"]=6,["adventrising"]=10,["aeonflux"]=6,["afllive2003"]=10,["afllive2004"]=10,["afllivepremiershipedition"]=10,
	["aflpremiership2005"]=10,["aggressiveinline"]=7,["airforcedeltastorm"]=1,["alias"]=1,["alienhominid"]=10,["aliensversuspredatorextinction"]=1,
	["allstarbaseball2003"]=8,["allstarbaseball2004"]=7,["americanchopper"]=6,["americanchopper2fullthrottle"]=10,["americanidolprototype"]=10,["americasarmyriseofasoldier"]=10,
	["amfbowling2004"]=10,["amped2"]=9,["ampedfreestylesnowboarding"]=1,["and1streetball"]=10,["angelicconcert"]=10,["animaniacsthegreatedgarhunt"]=10,
	["antzextremeracing"]=6,["aoinamida"]=5,["apex"]=10,["aquamanbattleforatlantis"]=7,["arcticthunder"]=10,["area51"]=10,
	["arenafootball"]=10,["armedanddangerous"]=10,["armymenmajormalfunction"]=10,["armymensargeswar"]=1,["arxfatalis"]=10,["atarianthology"]=1,
	["atvquadpowerracing2"]=1,["automodellista"]=10,["avatarthelastairbender"]=10,["backyardwrestling2theregoestheneighborhood"]=10,["backyardwrestlingdonttrythisathome"]=10,["badboysmiamitakedown"]=7,
	["baldursgatedarkalliance"]=10,["baldursgatedarkallianceii"]=1,["barbarian"]=10,["barbiehorseadventureswildhorserescue"]=1,["bassproshopstrophybass2007"]=10,["bassproshopstrophyhunter2007"]=10,
	["batmanbegins"]=1,["batmandarktomorrow"]=10,["batmanriseofsintzu"]=10,["batmanvengeance"]=10,["battleengineaquila"]=1,["battlefield2moderncombat"]=6,
	["battlestargalactica2003"]=1,["beatdownfistsofvengeance"]=10,["beyondgoodevil"]=10,["bigbumpin"]=6,["bigmuthatruckers"]=7,["bigmuthatruckers2"]=6,
	["bionicle"]=10,["bistrocupid"]=7,["bistrocupid2"]=10,["black"]=7,["blackstonemagicsteel"]=6,["bladeii"]=10,
	["blazingangelssquadronsofwwii"]=10,["blinx2mastersoftimespace"]=10,["blinxthetimesweeper"]=10,["blitztheleague"]=10,["bloodomen2"]=11,["bloodrayne"]=6,
	["bloodrayne2"]=10,["bloodwake"]=6,["bloodyroarextreme"]=11,["blowout"]=10,["bmxxxx"]=1,["braveknight"]=10,
	["breakdown"]=11,["breederscupworldthoroughbredchampionships"]=10,["brianlarainternationalcricket2005"]=10,["brokenswordthesleepingdragon"]=10,["bruteforce"]=1,["buffythevampireslayer"]=7,
	["buffythevampireslayerchaosbleeds"]=1,["burnout"]=10,["burnout2pointofimpact"]=10,["burnout3takedown"]=9,["burnoutrevenge"]=10,["cabelasbiggamehunter2005adventures"]=10,
	["cabelasdangeroushunts2"]=6,["cabelasdeerhunt2005season"]=6,["cabelasoutdooradventures"]=6,["callofcthulhudarkcornersoftheearth"]=6,["callofduty2bigredone"]=10,["callofduty3"]=10,
	["callofdutyfinesthour"]=1,["capcomclassicscollection"]=6,["capcomclassicscollectionvol2"]=6,["capcomfightingevolution"]=10,["capcomvssnk2eo"]=10,["cars"]=10,
	["carve"]=10,["castlevaniacurseofdarkness"]=10,["catcyberattackteam"]=10,["catwoman"]=7,["celdamage"]=6,["celebritydeathmatch"]=10,
	["championshipbowling"]=6,["championshipmanager2006"]=10,["championshipmanager5"]=10,["charlieandthechocolatefactory"]=6,["chessmaster"]=6,["chicagoenforcer"]=1,
	["circusmaximuschariotwars"]=1,["classifiedthesentinelcrisis"]=10,["closecombatfirsttofight"]=1,["clubfootball"]=10,["clubfootball2005"]=10,["codenamekidsnextdooroperationvideogame"]=6,
	["coldfear"]=10,["coldwar"]=10,["colinmcraerally04"]=1,["colinmcraerally2005"]=10,["colinmcraerally3"]=6,["collegehoops2k6"]=10,
	["collegehoops2k7"]=10,["combatelitewwiiparatroopers"]=1,["commandos2menofcourage"]=1,["commandosstrikeforce"]=10,["conan"]=10,["conflictdesertstorm"]=1,
	["conflictdesertstormiibacktobaghdad"]=11,["conflictglobalterror"]=6,["conflictvietnam"]=6,["conkerlivereloaded"]=9,["conspiracyweaponsofmassdestruction"]=10,["constantine"]=1,
	["corvette"]=10,["counterstrike"]=8,["counterterroristspecialforcesfireforeffectworks"]=6,["crashbandicootthewrathofcortex"]=10,["crashnburn"]=2,["crashnitrokart"]=8,
	["crashtwinsanity"]=1,["crazytaxi3highroller"]=10,["cricket2005"]=10,["crimelifegangwars"]=10,["crimsonsea"]=6,["crimsonskieshighroadtorevenge"]=1,
	["crouchingtigerhiddendragon"]=1,["crustydemons"]=6,["csicrimesceneinvestigation"]=10,["cursetheeyeofisis"]=10,["daisenryakuviimodernmilitarytactics"]=10,["dakar2theworldsultimaterally"]=10,
	["dancedancerevolutionultramix"]=10,["dancedancerevolutionultramix2"]=10,["dancedancerevolutionultramix3"]=10,["dancedancerevolutionultramix4"]=10,["danceuk"]=10,["darksummit"]=10,
	["darkwatch"]=1,["davemirrafreestylebmx2"]=11,["davidbeckhamsoccer"]=10,["deadmanshand"]=10,["deadoralive3"]=10,["deadoraliveultimatedoa1disc"]=7,
	["deadoraliveultimatedoa2disc"]=3,["deadoralivextremebeachvolleyball"]=3,["deadtorights"]=8,["deadtorightsii"]=10,["deathrow"]=1,["defender"]=10,
	["deltaforceblackhawkdown"]=6,["destroyallhumans"]=8,["destroyallhumans2"]=10,["deusexinvisiblewar"]=10,["diehardvendetta"]=10,["digimonrumblearena2"]=8,
	["digimonworld4"]=10,["dinocrisis3"]=10,["dinosaurhuntingjap"]=10,["dinotopiathesunstoneodyssey"]=10,["disneypixarfindingnemo"]=10,["disneypixarratatouille"]=10,
	["disneyschickenlittle"]=10,["doom3"]=7,["doom3resurrectionofevil"]=10,["dragonballzsagas"]=10,["dragonslair3d"]=10,["drakeofthe99dragons"]=1,
	["dreamfallthelongestjourney"]=7,["driv3r"]=10,["driverparallellines"]=10,["drmuto"]=7,["dronez"]=10,["drseussthecatinthehat"]=3,
	["dungeonsdragonsheroes"]=10,["dynastywarriors3"]=10,["dynastywarriors4"]=8,["dynastywarriors5"]=10,["eggmaniaeggstrememadness"]=1,["enclave"]=10,
	["englandinternationalfootball"]=10,["enterthematrix"]=10,["eragon"]=10,["espncollegehoops"]=9,["espncollegehoops2k5"]=10,["espninternationalwintersports2002"]=10,
	["espnmajorleaguebaseball"]=7,["espnmlsextratime2002"]=1,["espnnba2k5"]=10,["espnnbabasketball"]=10,["espnnfl2k5"]=10,["espnnflfootball06"]=9,
	["espnnflprimetime2002"]=10,["espnnhl2k5"]=10,["espnnhlhockey"]=10,["evildeadafistfulofboomstick"]=8,["evildeadregeneration"]=11,["exaskeleton"]=8,
	["f12001"]=10,["f1careerchallenge"]=10,["fable"]=7,["fablethelostchapters"]=7,["falloutbrotherhoodofsteel"]=10,["familyguy"]=8,
	["fantastic4"]=10,["farcryinstincts"]=9,["farcryinstinctsevolution"]=10,["fatalframeiicrimsonbutterflydirectorscut"]=8,["fatalframespecialedition"]=7,["fifasoccer06"]=10,
	["fifasoccer07"]=10,["fifasoccer2003"]=1,["fifasoccer2004"]=1,["fifasoccer2005"]=10,["fifastreet"]=1,["fifastreet2"]=10,
	["fifaworldcupgermany2006"]=8,["fightclub"]=10,["fightnight2004"]=10,["fightnightround2"]=10,["fightnightround3"]=9,["filaworldtourtennis"]=10,
	["finalfightstreetwise"]=10,["fireblade"]=10,["flatout"]=7,["flatout2"]=10,["flightacademy"]=10,["fordboldmovesstreetracing"]=10,
	["fordmustangthelegendlives"]=1,["fordracing2"]=10,["fordracing3"]=10,["fordvschevy"]=8,["forgottenrealmsdemonstone"]=10,["forzamotorsport"]=7,
	["frankiedettoriracing"]=10,["freakyflyers"]=7,["freedomfighters"]=10,["freefall3050adunreleased"]=6,["freestylemetalx"]=10,["freestylestreetsoccer"]=10,
	["froggerancientshadow"]=1,["froggerbeyond"]=1,["fromrussiawithlove007"]=6,["fullspectrumwarrior"]=10,["fullspectrumwarriortenhammers"]=10,["furiouskarting"]=10,
	["futurama"]=1,["futuretacticstheuprising"]=10,["fuzionfrenzy"]=10,["galaxyangel"]=10,["galleon"]=10,["gauntletdarklegacy"]=6,
	["gauntletsevensorrows"]=7,["genetroopers"]=10,["genmaonimusha"]=1,["ghostmasterthegravenvillechronicles"]=10,["gladiatorswordofvengeance"]=10,["goblincommanderunleashthehorde"]=1,
	["godzilladestroyallmonstersmelee"]=10,["godzillasavetheearth"]=10,["goldeneyerogueagent"]=10,["gotcha"]=10,["grabbedbytheghoulies"]=7,["grandtheftautoiii"]=1,
	["grandtheftautosanandreas"]=1,["grandtheftautovicecity"]=1,["gravitygamesbikestreetvertdirt"]=1,["greghastingstournamentpaintball"]=1,["greghastingstournamentpaintballmaxd"]=10,["grooveriderslotcarthunder"]=1,
	["groupschallenge"]=2,["guiltygearisuka"]=10,["guiltygearx2reload"]=10,["gun"]=10,["gungriffonalliedstrike"]=10,["gunmetal"]=10,
	["gunvalkyrie"]=10,["halflife2"]=8,["halo2"]=2,["halo2multiplayermappack"]=1,["halocombatevolved"]=1,["hamsterballxboxlivearcade"]=10,
	["harrypotterandthechamberofsecrets"]=10,["harrypotterandthegobletoffire"]=1,["harrypotterandtheprisonerofazkaban"]=10,["harrypotterandthesorcerersstone"]=1,["harrypotterquidditchworldcup"]=10,["headhunterredemption"]=10,
	["hellokittyrollerrescue"]=10,["hemandefenderofgrayskullproto"]=1,["heroesofthepacific"]=10,["highheatmajorleaguebaseball2004"]=8,["highrollerscasino"]=1,["hitman2silentassassin"]=6,
	["hitmancontracts"]=1,["hotwheelsstunttrackchallenge"]=10,["hulk"]=1,["hummerbadlands"]=10,["hunterthereckoning"]=10,["hunterthereckoningredeemer"]=10,
	["iceage2themeltdown"]=10,["ihradragracing2004"]=10,["ihradragracingsportsmanedition"]=1,["ihraprofessionaldragracing2005"]=1,["indianajonesandtheemperorstomb"]=10,["indigoprophecy"]=8,
	["indycarseries"]=10,["indycarseries2005"]=7,["ininja"]=8,["innocenttears"]=10,["insidepitch2003"]=10,["intellivisionlives"]=7,
	["internationalsuperstarsoccer2"]=10,["ironphoenix"]=10,["jacked"]=10,["jadeempire"]=1,["jamesbond007agentunderfire"]=6,["jamesbond007everythingornothing"]=10,
	["jamescameronsdarkangel"]=1,["jawsunleashed"]=10,["jikkyouworldsoccer2002"]=10,["jsrfjetsetradiofuture"]=10,["judgedredddreddvsdeath"]=1,["juiced"]=10,
	["jurassicparkoperationgenesis"]=10,["justcause"]=10,["justiceleagueheroes"]=9,["kabukiwarriors"]=8,["kakutochojin"]=6,["kameoelementsofpower"]=10,
	["kaothekangarooround2"]=10,["karaokerevolution"]=10,["karaokerevolutionparty"]=10,["kellyslatersprosurfer"]=1,["kikouheidanjphoenisplus"]=10,["killswitch"]=7,
	["kingarthur"]=9,["kingdomunderfireheroes"]=10,["kingdomunderfirethecrusaders"]=10,["kingoffightersmaximumimpactmaniax"]=10,["knightsapprenticememoricksadventures"]=10,["knightsofthetempleii"]=10,
	["knightsofthetempleinfernalcrusade"]=10,["knockoutkings2002"]=10,["kungfuchaos"]=10,["lamborghiniunreleased"]=11,["landofthedeadroadtofiddlersgreen"]=10,["largowinchempireunderthreat"]=6,
	["larush"]=10,["legendsofwrestlingii"]=10,["legostarwarsiitheoriginaltrilogy"]=8,["legostarwarsthevideogame"]=7,["leisuresuitlarrymagnacumlaude"]=8,["lemonysnicketsaseriesofunfortunateevents"]=1,
	["links2004"]=10,["lmamanager2003"]=10,["lmamanager2004"]=10,["lmamanager2005"]=10,["lmamanager2006"]=10,["loonsthefightforfame"]=1,
	["macegriffinbountyhunter"]=10,["madagascar"]=10,["maddashracing"]=10,["maddennfl06"]=10,["maddennfl07"]=10,["maddennfl08"]=10,
	["maddennfl09"]=10,["maddennfl2002"]=10,["maddennfl2003"]=10,["maddennfl2004"]=10,["maddennfl2005"]=10,["magatama"]=8,
	["magicthegatheringbattlegrounds"]=10,["majorleaguebaseball2k5"]=10,["majorleaguebaseball2k6"]=10,["majorleaguebaseball2k7"]=10,["malice"]=6,["manhunt"]=1,
	["marceckosgettingupcontentsunderpressure"]=10,["marvelnemesisriseoftheimperfects"]=9,["marvelultimatealliance"]=10,["marvelvscapcom2"]=10,["mashed"]=10,["mathoffmansprobmx2"]=1,
	["maximumchase"]=8,["maxpayne"]=1,["maxpayne2thefallofmaxpayne"]=1,["mechassault"]=7,["mechassault2lonewolf"]=10,["medalofhonoreuropeanassault"]=10,
	["medalofhonorfrontline"]=1,["medalofhonorrisingsun"]=1,["megamananniversarycollection"]=1,["menofvalor"]=10,["mercenariesplaygroundofdestruction"]=10,["metalarmsglitchinthesystem"]=10,
	["metalgearsolid2substance"]=10,["metalslug3"]=10,["metalslug4"]=10,["metalslug5"]=10,["miamivice"]=10,["micromachines"]=1,
	["midnightclub3dubedition"]=10,["midnightclub3dubeditionremix"]=10,["midnightclubii"]=10,["midtownmadness3"]=10,["midwayarcadetreasures"]=10,["midwayarcadetreasures2"]=10,
	["miketysonheavyweightboxing"]=1,["minorityreporteverybodyruns"]=7,["missionimpossibleoperationsurma"]=10,["mlbslugfest2003"]=10,["mlbslugfest2004"]=7,["mlbslugfest2006"]=10,
	["mlbslugfestloaded"]=10,["mojo"]=10,["monopolyparty"]=10,["monster4x4worldcircuit"]=10,["monstergarage"]=1,["mortalkombatarmageddon"]=9,
	["mortalkombatdeadlyalliance"]=10,["mortalkombatdeception"]=9,["mortalkombatshaolinmonks"]=10,["motocrossmania3"]=10,["motogp"]=9,["motogp2"]=9,
	["motogp3ultimateracingtechnology"]=10,["motortrendpresentslotuschallenge"]=10,["mtvmusicgenerator3thisistheremix"]=1,["mtxmototrax"]=10,["murakumorenegademechpursuit"]=1,["muzzleflash"]=10,
	["mvp06ncaabaseball"]=10,["mvpbaseball2003"]=9,["mvpbaseball2004"]=9,["mvpbaseball2005"]=10,["mx2002featuringrickycarmichael"]=10,["mxsuperfly"]=11,
	["mxunleashed"]=10,["mxvsatvunleashed"]=10,["mxworldtourfeaturingjamielittle"]=10,["mystiiiexile"]=10,["mystivrevelation"]=10,["namcomuseum"]=1,
	["namcomuseum50thanniversary"]=8,["narc"]=10,["nascar06totalteamcontrol"]=10,["nascar07"]=10,["nascar2005chaseforthecup"]=10,["nascarheat2002"]=10,
	["nascarthunder2002"]=10,["nascarthunder2003"]=10,["nascarthunder2004"]=10,["nba2k2"]=10,["nba2k3"]=10,["nba2k6"]=10,
	["nba2k7"]=10,["nbaballers"]=10,["nbaballersphenom"]=10,["nbainsidedrive2002"]=10,["nbainsidedrive2003"]=10,["nbainsidedrive2004"]=10,
	["nbalive06"]=10,["nbalive07"]=9,["nbalive2002"]=10,["nbalive2003"]=10,["nbalive2004"]=1,["nbalive2005"]=10,
	["nbastartingfive"]=10,["nbastreetv3"]=10,["nbastreetvol2"]=10,["ncaacollegebasketball2k3"]=10,["ncaacollegefootball2k3"]=10,["ncaafootball06"]=9,
	["ncaafootball07"]=10,["ncaafootball08"]=10,["ncaafootball2004"]=10,["ncaafootball2005"]=10,["ncaafootball2005topspincombo"]=10,["ncaamarchmadness06"]=10,
	["ncaamarchmadness2004"]=10,["ncaamarchmadness2005"]=10,["needforspeedcarbon"]=10,["needforspeedhotpursuit2"]=10,["needforspeedmostwanted2005"]=3,["needforspeedunderground"]=9,
	["needforspeedunderground2"]=10,["neighboursfromhell"]=1,["newlegends"]=10,["nfl2k2"]=11,["nfl2k3"]=9,["nflblitz2002"]=1,
	["nflblitz2003"]=1,["nflblitzpro"]=1,["nflfever2002"]=11,["nflfever2003"]=10,["nflfever2004"]=9,["nflheadcoach"]=10,
	["nflstreet"]=10,["nflstreet2"]=10,["nhl06"]=10,["nhl07"]=10,["nhl2002"]=10,["nhl2003"]=10,
	["nhl2004"]=1,["nhl2005"]=10,["nhl2k3"]=10,["nhl2k6"]=10,["nhl2k7"]=10,["nhlhitz2002"]=10,
	["nhlhitz2003"]=1,["nhlhitzpro"]=10,["nhlrivals2004"]=10,["nickelodeonpartyblast"]=10,["nightcaster"]=10,["nightcasteriiequinox"]=10,
	["ninjagaiden"]=7,["ninjagaidenblack"]=7,["nobunaganoyabouranseiki"]=10,["obscure2005"]=10,["oddworldmunchsoddysee"]=10,["oddworldstrangerswrath"]=10,
	["openseason"]=9,["operationflashpointelite"]=10,["otogi2immortalwarriors"]=10,["otogimythofdemons"]=10,["outlawgolf2"]=1,["outlawgolf9holesofxmas"]=10,
	["outlawgolf9moreholesofxmas"]=9,["outlawtennis"]=8,["outlawvolleyball"]=10,["outlawvolleyballredhot"]=10,["outrun2"]=9,["outrun2006coast2coast"]=6,
	["overthehedge"]=8,["pacmanworld2"]=10,["pacmanworld3"]=10,["painkillerhellwars"]=10,["panzerdragoonorta"]=10,["panzereliteactionfieldsofglory"]=7,
	["pariah"]=9,["peterjacksonskingkongtheofficialgameofthemovie"]=10,["petitcopter"]=10,["phantasystaronlineepisodeiii"]=10,["phantomcrash"]=1,["phantomdust"]=10,
	["pilotdownbehindenemylines"]=10,["pinballhalloffamethegottliebcollection"]=1,["piratesofthecaribbean"]=10,["piratesthelegendofblackkat"]=10,["pitfallthelostexpedition"]=1,["playboythemansion"]=10,
	["plusplumb2"]=10,["pocketbikeracer"]=10,["poolshark2"]=10,["powerdrome"]=10,["predatorconcretejungle"]=1,["princeofpersiathesandsoftime"]=1,
	["princeofpersiathetwothrones"]=10,["princeofpersiawarriorwithin"]=10,["prisonerofwar"]=10,["procastsportsfishing"]=10,["proevolutionsoccer4"]=6,["proevolutionsoccer5"]=6,
	["profishingchallenge"]=10,["projectgothamracing"]=10,["projectgothamracing2"]=10,["projectsnowblind"]=10,["proracedriver"]=1,["prostrokegolfworldtour2007"]=10,
	["psiopsthemindgateconspiracy"]=10,["psychonauts"]=9,["psyvariar2extendedition"]=10,["pumpitupexceed"]=1,["purepinball"]=1,["puyopopfever"]=1,
	["quantumredshift"]=1,["rallisportchallenge"]=7,["rallisportchallenge2"]=10,["rallyfusionraceofchampions"]=10,["rapalaprofishing"]=8,["rayman3hoodlumhavoc"]=10,
	["raymanarena"]=1,["razeshell"]=1,["realworldgolf"]=10,["redcard2003"]=1,["reddeadrevolver"]=1,["redfactionii"]=1,
	["redninjaendofhonor"]=10,["reignoffire"]=10,["rentaherono1"]=10,["reservoirdogs"]=10,["returntocastlewolfensteintidesofwar"]=10,["revoltbeta"]=10,
	["richardburnsrally"]=7,["rlhrunlikehell"]=10,["roadkill"]=10,["robinhooddefenderofthecrown"]=10,["robotechbattlecry"]=1,["robots"]=10,
	["robotsmultiplayerxboxracinggame"]=10,["robotwarsextremedestruction"]=10,["rocky"]=11,["rockylegends"]=1,["rogueops"]=1,["roguetrooper"]=7,
	["rracingevolution"]=10,["rugby06"]=10,["rugby2005"]=10,["rugbychallenge2006"]=10,["rugbyleague"]=10,["rugbyleague2"]=10,
	["samuraishodownv"]=10,["samuraiwarriors"]=1,["scaler"]=10,["scarfacetheworldisyours"]=10,["scarsquadracorsealfaromeo"]=10,["scoobydoomysterymayhem"]=10,
	["scoobydoonightof100frights"]=1,["scoobydoounmasked"]=10,["scrapland"]=1,["seablade"]=10,["seaworldshamusdeepseaadventures"]=1,["secondsight"]=4,
	["secretweaponsovernormandy"]=10,["segagt2002"]=10,["segagtonline"]=10,["segasoccerslam"]=1,["sensiblesoccer2006"]=10,["serioussam"]=8,
	["shadowofmemories"]=10,["shadowopsredmercury"]=10,["shadowthehedgehog"]=1,["sharktale"]=9,["shatteredunion"]=10,["shellshocknam67"]=1,
	["shenmueii"]=9,["shikigaminoshiroii"]=10,["shinchoumahjongnobunagamahjong"]=10,["shinmegamitenseinine"]=10,["showdownlegendsofwrestling"]=10,["shrek"]=10,
	["shrek2"]=9,["shreksuperparty"]=10,["shreksuperslam"]=10,["sidmeierspirates"]=8,["silenthill2restlessdreams"]=9,["silenthill4theroom"]=7,
	["silentscopecomplete"]=10,["skiracing2005featuringhermannmaier"]=10,["skiracing2006"]=10,["slamtennis"]=10,["smashingdrive"]=7,["sneakers"]=8,
	["sneakking"]=10,["sniperelite"]=10,["soldieroffortuneiidoublehelix"]=10,["sonicheroes"]=1,["sonicmegacollectionplus"]=1,["sonicriders"]=10,
	["soulcaliburii"]=10,["spartantotalwarrior"]=10,["spawnarmageddon"]=7,["specialforcesnemesisstrike"]=10,["speedkings"]=1,["sphinxandthecursedmummy"]=1,
	["spiderman"]=7,["spiderman2"]=10,["spikeoutbattlestreet"]=10,["splashdown"]=10,["splatrenegadepaintball"]=1,["spongebobsquarepantsbattleforbikinibottom"]=1,
	["spongebobsquarepantslightscamerapants"]=9,["spyhunter"]=10,["spyhunter2"]=1,["spyhunternowheretorun"]=10,["spyroaherostail"]=1,["ssx3"]=7,
	["ssxontour"]=10,["ssxtricky"]=10,["stackedwithdanielnegreanu"]=10,["stakefortunefighters"]=1,["starskyhutch"]=10,["startrekshattereduniverse"]=10,
	["starwarsbattlefront"]=7,["starwarsbattlefrontii"]=7,["starwarsepisodeiiirevengeofthesith"]=1,["starwarsjediknightiijedioutcast"]=10,["starwarsjediknightjediacademy"]=1,["starwarsjedistarfighter"]=10,
	["starwarsjedistarfighterspecialedition"]=10,["starwarsknightsoftheoldrepublic"]=1,["starwarsknightsoftheoldrepubliciithesithlords"]=1,["starwarsobiwan"]=6,["starwarsrepubliccommando"]=10,["starwarsstarfighterspecialedition"]=10,
	["starwarstheclonewars"]=10,["stateofemergency"]=7,["stikmars"]=10,["stilllife"]=10,["stolen"]=10,["streetfighteranniversarycollection"]=10,
	["streethoops"]=10,["streetracingsyndicate"]=1,["strikeforcebowling"]=10,["stubbsthezombieinrebelwithoutapulse"]=1,["sudeki"]=10,["superbubblepop"]=1,
	["supermanreturns"]=10,["supermanthemanofsteel"]=10,["supermonkeyballdeluxe"]=1,["svcchaossnkvscapcom"]=10,["swatglobalstriketeam"]=10,["sxsuperstar"]=1,
	["syberia"]=10,["syberiaii"]=10,["tak2thestaffofdreams"]=10,["takahashijunkonomahjongseminar"]=10,["takthegreatjujuchallenge"]=10,["tazwanted"]=8,
	["tdoverdrivethebrotherhoodofspeed"]=10,["tecmoclassicarcade"]=10,["teenagemutantninjaturtles"]=1,["teenagemutantninjaturtles2battlenexus"]=10,["teenagemutantninjaturtles3mutantnightmare"]=10,["teentitans"]=10,
	["tenchureturnfromdarkness"]=10,["tenerezza"]=10,["tennismastersseries2003"]=10,["terminator3riseofthemachines"]=10,["terminator3theredemption"]=10,["testdrive"]=10,
	["testdriveeveofdestruction"]=1,["testdriveoffroadwideopen"]=10,["tetrisworlds"]=1,["tetrisworldsonlineedition"]=10,["thebardstale"]=10,["thebiblegame"]=10,
	["thechroniclesofnarniathelionthewitchandthewardrobe"]=10,["thedavincicode"]=10,["thedukesofhazzardreturnofthegenerallee"]=10,["theelderscrollsiiimorrowind"]=10,["theelderscrollsiiimorrowindgameoftheyearedition"]=10,["thefairlyoddparentsbreakindarules"]=1,
	["thegodfather"]=10,["thegreatescape"]=1,["theguygame"]=10,["thehauntedmansion"]=10,["thehouseofthedeadiii"]=1,["thehustledetroitstreets"]=10,
	["theincrediblehulkultimatedestruction"]=1,["theincredibles"]=8,["theincrediblesriseoftheunderminer"]=7,["theitalianjob"]=10,["thekingoffighters2002"]=10,["thekingoffighters2003"]=10,
	["thekingoffighters94rebout"]=10,["thekingoffightersneowave"]=10,["thelegendofspyroanewbeginning"]=8,["thelordoftheringsthefellowshipofthering"]=10,["thelordoftheringsthereturnoftheking"]=1,["thelordoftheringsthethirdage"]=10,
	["thelordoftheringsthetwotowers"]=10,["thematrixpathofneo"]=10,["thepunisher"]=1,["theredstarunreleased"]=10,["thesimpsonshitrun"]=1,["thesimpsonsroadrage"]=1,
	["thesims"]=10,["thesims2"]=10,["thesimsbustinout"]=10,["thespongebobsquarepantsmovie"]=10,["thesuffering"]=10,["thesufferingtiesthatbind"]=10,
	["theterminatordawnoffate"]=1,["thething"]=1,["theurbzsimsinthecity"]=10,["thewarriors"]=10,["thewildringsjap"]=10,["thiefdeadlyshadows"]=1,
	["thousandland"]=10,["thrillville"]=10,["tigerwoodspgatour06"]=10,["tigerwoodspgatour07"]=10,["tigerwoodspgatour2003"]=10,["tigerwoodspgatour2004"]=10,
	["tigerwoodspgatour2005"]=10,["timburtonsthenightmarebeforechristmasoogiesrevenge"]=10,["timesplitters2"]=6,["timesplittersfutureperfect"]=6,["tmntmutantmelee"]=9,["tocaracedriver"]=10,
	["tocaracedriver2"]=10,["tocaracedriver3"]=10,["toejamearliiimissiontoearth"]=10,["tomclancysghostrecon"]=3,["tomclancysghostrecon2"]=3,["tomclancysghostrecon2summitstrike"]=3,
	["tomclancysghostreconadvancedwarfighter"]=10,["tomclancysghostreconislandthunder"]=8,["tomclancysrainbowsix3"]=10,["tomclancysrainbowsix3blackarrow"]=10,["tomclancysrainbowsixcriticalhour"]=10,["tomclancysrainbowsixlockdown"]=10,
	["tomclancyssplintercell"]=3,["tomclancyssplintercellchaostheory"]=7,["tomclancyssplintercelldoubleagent"]=9,["tomclancyssplintercellpandoratomorrow"]=3,["tomjerryinwarofthewhiskers"]=10,["tonyhawksamericanwasteland"]=1,
	["tonyhawksproject8"]=10,["tonyhawksproskater2x"]=10,["tonyhawksproskater3"]=10,["tonyhawksproskater4"]=1,["tonyhawksunderground"]=10,["tonyhawksunderground2"]=1,
	["topgearrpmtuning"]=10,["topspin"]=10,["torino2006"]=7,["torkprehistoricpunk"]=1,["totalclubmanager2005"]=10,["totaled"]=10,
	["totalimmersionracing"]=10,["totaloverdoseagunslingerstaleinmexico"]=10,["touger"]=6,["toxicgrind"]=10,["transworldsnowboarding"]=10,["transworldsurf"]=10,
	["triangleagain2"]=10,["triggerman"]=7,["tripleplay2002"]=10,["trivialpursuitunhinged"]=9,["tron20killerapp"]=10,["truecrimenewyorkcity"]=10,
	["truecrimestreetsofla"]=8,["turokevolution"]=10,["tythetasmaniantiger"]=1,["tythetasmaniantiger2bushrescue"]=1,["tythetasmaniantiger3nightofthequinkan"]=1,["uefachampionsleague20042005"]=10,
	["uefaeuro2004portugal"]=1,["ufctapout2"]=10,["ultimatebeachsoccer"]=10,["ultimatepropinball"]=10,["ultimatespiderman"]=8,["ultrabustamove"]=9,
	["umezawayukarinoigoseminar"]=10,["unrealchampionship"]=10,["unrealchampionship2theliandriconflict"]=10,["unrealiitheawakening"]=10,["urbanchaosriotresponse"]=10,["usopen2003"]=10,
	["vanhelsing"]=10,["vexx"]=1,["vietcongpurplehaze"]=7,["virtualpooltournamentedition"]=10,["volvodriveforlife"]=1,["vrally3"]=10,
	["wakeboardingunleashedfeaturingshaunmurray"]=8,["wallaceandgromitcurseofthewererabbit"]=9,["wallacegromitinprojectzoo"]=10,["warpath"]=10,["whacked"]=8,["whiplash"]=10,
	["whiteout"]=10,["winback2projectposeidon"]=8,["wingsofwar"]=10,["withoutwarning"]=10,["worldbilliardstournamentbreaknine"]=10,["worldchampionshippoker"]=10,
	["worldchampionshippoker2featuringhowardlederer"]=10,["worldchampionshippool2004"]=10,["worldchampionshiprugby"]=10,["worldchampionshipsnooker2003"]=10,["worldchampionshipsnooker2004"]=10,["worldpokertour"]=10,
	["worldracing"]=10,["worldracing2"]=10,["worldseriesbaseball"]=10,["worldseriesbaseball2k3"]=7,["worldseriesofpoker"]=10,["worldsnookerchampionship2005"]=10,
	["worldsoccerwinningeleven8international"]=10,["worldsoccerwinningeleven9"]=7,["worldwariicombatiwojima"]=10,["worldwariicombatroadtoberlin"]=10,["worms3d"]=10,["worms4mayhem"]=1,
	["wormsfortsundersiege"]=1,["wrathunleashed"]=7,["wtatourtennis"]=10,["wweraw2"]=1,["wwewrestlemania21"]=10,["wwfraw"]=10,
	["x2wolverinesrevenge"]=8,["xgraextremegracingassociation"]=10,["xiaolinshowdown"]=8,["xiii"]=1,["xmenlegends"]=10,["xmenlegendsiiriseofapocalypse"]=10,
	["xmennextdimension"]=10,["xmentheofficialgame"]=10,["xyanide"]=10,["yager"]=10,["yetisportsarcticadventure"]=10,["yourselffitness"]=1,
	["yugiohthedawnofdestiny"]=10,["zapper"]=7,["zathura"]=10,["zillernet"]=10
}

-- Mesma normalizacao usada ao gerar a tabela: minusculas, sem acentos,
-- so letras e numeros.
local ACENTOS = {
	["\195\161"]="a",["\195\160"]="a",["\195\162"]="a",["\195\163"]="a",["\195\164"]="a",
	["\195\169"]="e",["\195\168"]="e",["\195\170"]="e",["\195\171"]="e",
	["\195\173"]="i",["\195\172"]="i",["\195\174"]="i",["\195\175"]="i",
	["\195\179"]="o",["\195\178"]="o",["\195\180"]="o",["\195\181"]="o",["\195\182"]="o",
	["\195\186"]="u",["\195\185"]="u",["\195\187"]="u",["\195\188"]="u",
	["\195\167"]="c",["\195\177"]="n",
}

local function normalizar(s)
	if type(s) ~= "string" then return "" end
	s = s:lower()
	for k, v in pairs(ACENTOS) do s = s:gsub(k, v) end
	return (s:gsub("[^a-z0-9]", ""))
end

-- cache em memoria: evita reescrever quando ja esta aplicado
local atual = nil

-- Ligado por padrao: so fica desligado se o arquivo de "off" existir.
local function ligado()
	return not FileSystem.FileExists(DESLIGADO)
end

local function aplicar(arquivo, titulo)
	if not FileSystem.FileExists(BACKUP .. arquivo) then return false end
	for i = 1, #SLOTS do
		FileSystem.CopyFile(BACKUP .. arquivo, COMPAT .. SLOTS[i], true)
	end
	if titulo and FileSystem.FileExists(BACKUP .. titulo) then
		for i = 1, #SLOTS_TITLE do
			FileSystem.CopyFile(BACKUP .. titulo, COMPAT .. SLOTS_TITLE[i], true)
		end
	end
	FileSystem.WriteFile(ESTADO, arquivo)
	return true
end

-- Aplica o xefu do jogo. Devolve o nome curto do xefu (ou nil).
-- Acha o xefu do jogo: primeiro pelo TitleId (exato), depois pelo nome.
-- O nome vem do proprio Aurora, entao funciona em qualquer console.
local function achar(Content)
	local i = MAPA[Content.TitleId]
	if i then return i end

	for _, campo in ipairs({Content.Name, Content.TitleName, Content.Directory}) do
		if type(campo) == "string" and #campo > 0 then
			-- Directory vem como "\Xbox Original\Nome do Jogo"
			local so_nome = campo:match("([^\\]+)$") or campo
			i = POR_NOME[normalizar(so_nome)]
			if i then return i end
		end
	end
	return nil
end

local function trocar(Content)
	local i = achar(Content)
	if not i then return nil end
	local arquivo = XEFUS[i]
	if not ligado() then
		return arquivo:gsub("%.xex$", "") .. " (off)"
	end
	-- Compara pelo TAMANHO do arquivo que esta no slot com o do original
	-- no XefuBackup. E a fonte da verdade: nao depende de cache nem de
	-- arquivo de registro, entao nunca "acha" que ja aplicou sem ter
	-- aplicado.
	local ok1, atualTam = pcall(FileSystem.GetFileSize, COMPAT .. "xefu.xex")
	local ok2, alvoTam = pcall(FileSystem.GetFileSize, BACKUP .. arquivo)
	if not (ok1 and ok2 and atualTam == alvoTam and atualTam > 0) then
		aplicar(arquivo, TITLES[i])
	end
	return arquivo:gsub("%.xex$", "")
end

-- 1) subtitulo proprio, para quem quiser ver so o xefu
GameListSubtitles["Xefu Auto"] = function(Content)
	local nome = trocar(Content)
	if not nome then return "" end
	return "xefu: " .. nome
end

-- 2) engancha nos subtitulos que ja existem, para funcionar
--    sem precisar trocar nada nas opcoes do Aurora.
--    Monta a lista primeiro e so depois substitui, para nao alterar
--    a tabela enquanto o pairs() percorre ela.
local function engancharTodos()
	local alvos = {}
	for chave, original in pairs(GameListSubtitles) do
		if chave ~= "Xefu Auto" and type(original) == "function" then
			alvos[#alvos + 1] = { chave = chave, original = original }
		end
	end
	for _, a in ipairs(alvos) do
		local original = a.original
		GameListSubtitles[a.chave] = function(Content)
			pcall(trocar, Content)
			local ok, texto = pcall(original, Content)
			if ok then return texto end
			return ""
		end
	end
	-- deixa rastro no debug.log para sabermos que o engate rodou
	print("XefuAuto: enganchei " .. #alvos .. " subtitulos")
end

pcall(engancharTodos)
