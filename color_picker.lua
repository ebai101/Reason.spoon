local colorPicker = {}
local app = hs.appfinder.appFromName('Reason')

colorPicker.colorList = {
	{
		name = 'Burgundy',
		hex = '#9D1D21'
	},
	{
		name = 'Red',
		hex = '#D62127'
	},
	{
		name = 'Orange',
		hex = '#DE5F26'
	},
	{
		name = 'Brown',
		hex = '#854F20'
	},
	{
		name = 'Ochre',
		hex = '#C27E29'
	},
	{
		name = 'Peach',
		hex = '#F1B17D'
	},
	{
		name = 'Wheat',
		hex = '#F3DCB2'
	},
	{
		name = 'Tangerine',
		hex = '#F8971E'
	},
	{
		name = 'Pineapple',
		hex = '#F8971E'
	},
	{
		name = 'Lemon',
		hex = '#F9EB1F'
	},
	{
		name = 'Bright Lime',
		hex = '#C4EB04'
	},
	{
		name = 'Light Olive',
		hex = '#A4C64B'
	},
	{
		name = 'Moss Green',
		hex = '#C6DAAD'
	},
	{
		name = 'Kelly Green',
		hex = '#379C47'
	},
	{
		name = 'Asparagus',
		hex = '#698443'
	},
	{
		name = 'Dark Green',
		hex = '#04551A'
	},
	{
		name = 'Camouflage Green',
		hex = '#677765'
	},
	{
		name = 'Turquoise',
		hex = '#1EB89E'
	},
	{
		name = 'Blue in Green',
		hex = '#068D99'
	},
	{
		name = 'Powder Blue',
		hex = '#8EB8C1'
	},
	{
		name = 'Light Blue',
		hex = '#A6C3DC'
	},
	{
		name = 'Sky Blue',
		hex = '#58B7E7'
	},
	{
		name = 'Steel Blue',
		hex = '#4470B6'
	},
	{
		name = 'Slate Blue',
		hex = '#5B6DA1'
	},
	{
		name = 'Dark Blue',
		hex = '#2B3682'
	},
	{
		name = 'Pink',
		hex = '#F9C8CA'
	},
	{
		name = 'Lilac',
		hex = '#B87AA1'
	},
	{
		name = 'Plum',
		hex = '#B34C9B'
	},
	{
		name = 'Neon Violet',
		hex = '#E61DC4'
	},
	{
		name = 'Deep Purple',
		hex = '#73138D'
	},
	{
		name = 'Graphite',
		hex = '#737373'
	},
	{
		name = 'Bright Grey',
		hex = '#C9C9C9'
	},
}

function colorPicker:setup(type)
	self.type = type
	self.chooser = hs.chooser.new(function(choice)
		return colorPicker:select(choice)
	end)
	self.chooser:width(20)
	self.chooser:choices(function()
		local list = {}
		for _, color in pairs(colorPicker.colorList) do
			table.insert(list, {
				['text'] = hs.styledtext.new(color.name, { font = { size = 18 }, color = { hex = color.hex } })
			})
		end
		return list
	end)
end

function colorPicker:show()
	self.chooser:show()
end

function colorPicker:select(choice)
	if not choice then return end
	local color = choice['text']:getString()
	print(color)
	local selector = { 'Edit', self.type, color }
	print(hs.inspect(selector))
	app:selectMenuItem(selector)
end

return colorPicker
