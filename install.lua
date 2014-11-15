local root = '/iliketurtles/'
local install = {
  'startup',
  'apis/inventory',
  'apis/orientation',
  'apis/position',
  'apis/queued',
  'apis/refuel',
  'apis/travel',
  'apis/restock',
  'programs/cacti-farmer',
  'programs/pumpkin-plower',
  'programs/pserver',
  'programs/floorist',
}

fs.delete(root)
for i, file in ipairs(install) do
  shell.run('github get whitehat101/iliketurtles/master/'..file..'.lua '..root..file)
end

if not fs.exists('/startup') then
  local file = fs.open('/startup','w')
  file.write("shell.run('/iliketurtles/startup')\n")
  file.close()
end

os.reboot()
