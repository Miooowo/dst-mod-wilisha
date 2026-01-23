---@type data_recipe[]

local data = {
	-- {
	-- 	recipe_name = 'choleknife_recipe_1', --配方ID
	-- 	ingredients = { --配方
	-- 		Ingredient('pack_gold',1), 
	-- 		Ingredient('rope',2), 
	-- 		Ingredient('log',2),
	-- 	},
	-- 	tech = TECH.SCIENCE_ONE, --所需科技 ,TECH.LOST 表示需要蓝图才能解锁
	-- 	isOriginalItem = false, --是官方物品(官方物品严禁写atlas和image路径,因为是自动获取的),不写则为自定义物品
	-- 	config ={ --其他的一些配置,可不写
	-- 		--制作出来的物品,不写则默认制作出来的预制物为食谱ID
	-- 		product = 'choleknife', 
	-- 		--xml路径,不写则默认路径为,'images/inventoryimages/'..product..'.xml' 或 'images/inventoryimages/'..recipe_name..'.xml'
	-- 		atlas = 'images/choleknife.xml',
	-- 		--图片名称,不写则默认名称为 product..'.tex' 或 recipe_name..'.tex'
	-- 		image = 'choleknife.tex',
	-- 		--制作出的物品数量,不写则为1
	-- 		numtogive = 40,
	-- 		--不需要解锁,填true则会导致该物品没有蓝图
	-- 		nounlock = false,
	-- 	},
	-- 	filters = {'CHARACTER'} --将物品添加到这些分类中
	-- },
	{
		recipe_name = 'wilisha_lunarplant_husk',
		ingredients = {
			Ingredient(CHARACTER_INGREDIENT.HEALTH, 20),
		},
		tech = TECH.NONE,
		isOriginalItem = true,
		config = {
			product = 'lunarplant_husk',
			builder_tag = "lunarthrall_plant",
			sg_state="form_husk", 
			actionstr="GROW", 
			allowautopick = true, 
			no_deconstruction=true,
			description = "livinglog"
		},
		filters = {'CHARACTER'},
	},
	{
		recipe_name = 'wilisha_moonglass_charged',
		ingredients = {
			Ingredient('moonglass', 2),
			Ingredient(CHARACTER_INGREDIENT.HEALTH, 10),
		},
		tech = TECH.NONE,
		isOriginalItem = true,
		config = {
			product = 'moonglass_charged',
			builder_tag = "lunarthrall_plant",
			description = "wilisha_moonglass_charged",
		},
		filters = {'CHARACTER'},
	},
	-- {
	-- 	recipe_name = 'wilisha_purebrilliance',
	-- 	ingredients = {
	-- 		Ingredient('moonglass_charged', 3),
	-- 		Ingredient(CHARACTER_INGREDIENT.SANITY, 5),
	-- 	},
	-- 	tech = TECH.NONE,
	-- 	isOriginalItem = true,
	-- 	config = {
	-- 		product = 'purebrilliance',
	-- 		builder_tag = "lunarthrall_plant",
	-- 		description = "transmute_purebrilliance",
	-- 	},
	-- 	filters = { 'CHARACTER' },
	-- },
	{
		recipe_name = 'lunarplant_seeds',
		ingredients = {
			Ingredient('lunarplant_husk', 2),
		},
		tech = TECH.NONE,
		isOriginalItem = false,
		config = {
			builder_tag = "lunarthrall_plant",
		},
		filters = {'CHARACTER'},
	},
}

---@type data_destruction_recipes[]
local destruction_recipes = {
}

return data,destruction_recipes