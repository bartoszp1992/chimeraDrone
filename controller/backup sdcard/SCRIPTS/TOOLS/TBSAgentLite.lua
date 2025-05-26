-------------------------------------------------------------------------------
-- TBS Agent Lite 0.98
-- release date: 2024-01
-- author: JimB40
-------------------------------------------------------------------------------
local toolName = "TNS|TBS Agent 0.98|TNE"
local SP = '/SCRIPTS/TOOLS/TBSAGENTLITE/'
return {run=(loadScript(SP..'loader','Tx')('SA',SP)).run}
