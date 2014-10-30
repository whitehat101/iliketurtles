local root = '/iliketurtles/'
local install = {
  'apis/orientation',
  'apis/position',
  'apis/queued',
  'apis/refuel',
  'apis/travel',
  'apis/startup',
  'programs/cacti-farmer',
}

fs.delete(root)
for i, file in ipairs(install) do
  shell.run('github get whitehat101/iliketurtles/master/'..file..' '..root..file)
end

if not fs.exists('/startup') then
  local file = fs.open('/startup')
  file.write("shell.run('/iliketurtles/startup')\n")
  file.close()
end
