package Classes.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.EmbeddedArt;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Events.DynamicObjectEvent;
   import Events.SuperBuildingCompleteEvent;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureOptionsManager;
   import Managers.OlyInnovationManager;
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingLevelUpWindow;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingNPCWindow;
   import flash.events.Event;
   
   public class FeatureCraftingSystem
   {
      
      public static const SYSTEM_XYT_ELITEHORSES:String = "xyt_elitehorses";
      
      public static const SYSTEM_XPU_ELITEHORSES:String = "xpu_elitehorses";
      
      public static const SYSTEM_XAH_ELITEHORSES:String = "xah_elitehorses";
      
      public static const SYSTEM_XCD_ELITEHORSES:String = "xcd_elitehorses";
      
      public static const SYSTEM_XDM_ELITEHORSES:String = "xdm_elitehorses";
      
      public static const SYSTEM_XBB_ELITEHORSES:String = "xbb_elitehorses";
      
      public static const SYSTEM_XMT_ELITEHORSES:String = "xmt_elitehorses";
      
      public static const SYSTEM_XFS_ELITEHORSES:String = "xfs_elitehorses";
      
      public static const SYSTEM_XWS_ELITEHORSES:String = "xws_elitehorses";
      
      public static const SYSTEM_XHF_ELITEHORSES:String = "xhf_elitehorses";
      
      public static const SYSTEM_XID_ELITEHORSES:String = "xid_elitehorses";
      
      public static const SYSTEM_XCL_ELITEHORSES:String = "xcl_elitehorses";
      
      public static const SYSTEM_XSU_ELITEHORSES:String = "xsu_elitehorses";
      
      public static const SYSTEM_XRT_ELITEHORSES:String = "xrt_elitehorses";
      
      public static const SYSTEM_XBL_ELITEHORSES:String = "xbl_elitehorses";
      
      public static const SYSTEM_XCA_ELITEHORSES:String = "xca_elitehorses";
      
      public static const SYSTEM_XWX_ELITEHORSES:String = "xwx_elitehorses";
      
      public static const SYSTEM_XHX_ELITEHORSES:String = "xhx_elitehorses";
      
      public static const SYSTEM_XIS_ELITEHORSES:String = "xis_elitehorses";
      
      public static const SYSTEM_XNF_ELITEHORSES:String = "xnf_elitehorses";
      
      public static const SYSTEM_XRU_ELITEHORSES:String = "xru_elitehorses";
      
      public static const SYSTEM_XCB_ELITEHORSES:String = "xcb_elitehorses";
      
      public static const SYSTEM_XDV_ELITEHORSES:String = "xdv_elitehorses";
      
      public static const SYSTEM_XTY_ELITEHORSES:String = "xty_elitehorses";
      
      public static const SYSTEM_XBR_ELITEHORSES:String = "xbr_elitehorses";
      
      public static const DEFAULT_NPC_NAME:String = "none";
      
      public static const SYSTEM_DAIRY_CRAFTING:String = "dairyCrafting";
      
      public static const SYSTEM_HORSE_CRAFTING:String = "horseCrafting";
      
      public static const SYSTEM_YARN_BARN:String = "yarnbarn";
      
      public static const SYSTEM_SWEET_SHOP:String = "sweetshop";
      
      public static const SYSTEM_APOTHECARY:String = "apothecary";
      
      public static const SYSTEM_HOLLYBRIGHT_PARK:String = "hollybrightpark";
      
      public static const SYSTEM_JUNGLE_HIDEAWAY:String = "junglehideaway";
      
      public static const SYSTEM_TINMAN_FOUNTAIN:String = "tinmanfountain";
      
      public static const SYSTEM_AZURE_EMPORIUM:String = "azureemporium";
      
      public static const SYSTEM_ARABIAN_STALLIONS:String = "arabianstallions";
      
      public static const SYSTEM_MAGICGARDEN:String = "magicgarden";
      
      public static const SYSTEM_BLACKJACKBARN:String = "blackjackbarn";
      
      public static const REWARDS_TYPE:String = "type";
      
      public static const REWARDS_VALUE:String = "value";
      
      public static const REWARDS_AMOUNT:String = "amount";
      
      public static const REWARDS_TYPE_COIN:String = "coins";
      
      public static const REWARDS_TYPE_ITEMGRANT:String = "item_grant";
      
      public static const REWARDS_TYPE_POINTS:String = "points";
      
      public static const REWARDS_TYPE_INVENTORYPARTS:String = "inventory_part";
      
      public static const ASSET_ICON_POINTS:String = "iconPoints";
      
      public static const DATAKEY_STORAGE:String = "storage";
      
      public static const DATAKEY_GOODS:String = "goods";
      
      public static const DATAKEY_ORDERBOARD:String = "orderBoard";
      
      public static const DATAKEY_MASTERY:String = "mastery";
      
      public static const DATAKEY_NPC_NAME:String = "npcName";
      
      public static const DATAKEY_STATIONS:String = "stations";
      
      public static const DATAKEY_POINTS:String = "points";
      
      public static const DATAKEY_ORDERS:String = "orders";
      
      public static const DATAKEY_REWARDS:String = "rewards";
      
      public static const DATAKEY_TIME_STAMP:String = "timeStamp";
      
      public static const DATAKEY_NPCS:String = "npcs";
      
      public static const ASSET_DIALOG_CONTENTS:String = "dialogContents";
      
      public static const ASSET_DIALOG_STORAGE:String = "dialogStorage";
      
      public static const ASSET_DIALOG_LEVEL_UP:String = "dialogLevelup";
      
      public static const ASSET_DIALOG_LEVEL_UP_UNLOCK:String = "dialogLevelupUnlock";
      
      public static const ASSET_DIALOG_ORDERS:String = "dialogOrders";
      
      public static const ASSET_DIALOG_RECIPE:String = "dialogRecipe";
      
      public static const ASSET_DIALOG_REWARD:String = "dialogReward";
      
      public static const ASSET_DIALOG_MASTERY:String = "dialogMastery";
      
      public static const ASSET_DIALOG_BACKGROUND:String = "dialogBackground";
      
      public static const ASSET_DIALOG_BACKGROUND_FRAME:String = "dialogBackgroundFrame";
      
      public static const GOOD_COST_MULTIPLIER:Number = 0.7;
      
      public static const HARVEST_NOW_MULTIPLIER:Number = 0.01;
      
      public static const SYSTEM_TOYSHOPPE:String = "toyshoppe";
      
      public static const SYSTEM_FORESTFAIR:String = "forestfair";
      
      public static const SYSTEM_ROYALSTABLE:String = "royalstable";
      
      public static const SYSTEM_RODEORANCH:String = "rodeoranch";
      
      public static const SYSTEM_TIDEHOMESTEAD:String = "tidehomestead";
      
      public static const SYSTEM_SAVANNAHRESERVE:String = "savannahreserve";
      
      public static const SYSTEM_XTR_ELITEHORSES:String = "xtr_elitehorses";
      
      public static const SYSTEM_XWI_ELITEHORSES:String = "xwi_elitehorses";
      
      public static const SYSTEM_XIN_ELITEHORSES:String = "xin_elitehorses";
      
      public static const SYSTEM_XJP_ELITEHORSES:String = "xjp_elitehorses";
      
      public static const SYSTEM_XJP_ELITEHORSES_MS:String = "xjp_elitehorses_ms";
      
      public static const SYSTEM_XJM_ELITEHORSES:String = "xjm_elitehorses";
      
      public static const SYSTEM_XMO_ELITEHORSES:String = "xmo_elitehorses";
      
      public static const SYSTEM_XBO_ELITEHORSES:String = "xbo_elitehorses";
      
      public static const SYSTEM_XCH_ELITEHORSES:String = "xch_elitehorses";
      
      public static const SYSTEM_XHH_ELITEHORSES:String = "xhh_elitehorses";
      
      public static const SYSTEM_XTI_ELITEHORSES:String = "xti_elitehorses";
      
      public static const SYSTEM_XDW_ELITEHORSES:String = "xdw_elitehorses";
      
      public static const SYSTEM_XFE_ELITEHORSES:String = "xfe_elitehorses";
      
      public static const SYSTEM_XUW_ELITEHORSES:String = "xuw_elitehorses";
      
      public static const SYSTEM_XHA_ELITEHORSES:String = "xha_elitehorses";
      
      public static const SYSTEM_XFW_ELITEHORSES:String = "xfw_elitehorses";
      
      public static const ACTIONMENU_ELITEHORSES_LIMIT:int = 3;
      
      public static const ALL_ELITEHORSES:Array = [[SYSTEM_XYT_ELITEHORSES,"ActionMenu_xyt_elitehorses",EmbeddedArt.hud_xyt_elitehorses,"onXyt_elitehorses"],[SYSTEM_XPU_ELITEHORSES,"ActionMenu_xpu_elitehorses",EmbeddedArt.hud_xpu_elitehorses,"onXpu_elitehorses"],[SYSTEM_XAH_ELITEHORSES,"ActionMenu_xah_elitehorses",EmbeddedArt.hud_xah_elitehorses,"onXah_elitehorses"],[SYSTEM_XCD_ELITEHORSES,"ActionMenu_xcd_elitehorses",EmbeddedArt.hud_xcd_elitehorses,"onXcd_elitehorses"],[SYSTEM_XDM_ELITEHORSES,"ActionMenu_xdm_elitehorses",EmbeddedArt.hud_xdm_elitehorses,"onXdm_elitehorses"],[SYSTEM_XBB_ELITEHORSES,"ActionMenu_xbb_elitehorses",EmbeddedArt.hud_xbb_elitehorses,"onXbb_elitehorses"],[SYSTEM_XMT_ELITEHORSES,"ActionMenu_xmt_elitehorses",EmbeddedArt.hud_xmt_elitehorses,"onXmt_elitehorses"],[SYSTEM_XFS_ELITEHORSES,"ActionMenu_xfs_elitehorses",EmbeddedArt.hud_xfs_elitehorses,"onXfs_elitehorses"],[SYSTEM_XWS_ELITEHORSES,"ActionMenu_xws_elitehorses",EmbeddedArt.hud_xws_elitehorses,"onXws_elitehorses"],[SYSTEM_XHF_ELITEHORSES
      ,"ActionMenu_xhf_elitehorses",EmbeddedArt.hud_xhf_elitehorses,"onXhf_elitehorses"],[SYSTEM_XID_ELITEHORSES,"ActionMenu_xid_elitehorses",EmbeddedArt.hud_xid_elitehorses,"onXid_elitehorses"],[SYSTEM_XCL_ELITEHORSES,"ActionMenu_xcl_elitehorses",EmbeddedArt.hud_xcl_elitehorses,"onXcl_elitehorses"],[SYSTEM_XSU_ELITEHORSES,"ActionMenu_xsu_elitehorses",EmbeddedArt.hud_xsu_elitehorses,"onXsu_elitehorses"],[SYSTEM_XRT_ELITEHORSES,"ActionMenu_xrt_elitehorses",EmbeddedArt.hud_xrt_elitehorses,"onXrt_elitehorses"],[SYSTEM_XBL_ELITEHORSES,"ActionMenu_xbl_elitehorses",EmbeddedArt.hud_xbl_elitehorses,"onXbl_elitehorses"],[SYSTEM_XCA_ELITEHORSES,"ActionMenu_xca_elitehorses",EmbeddedArt.hud_xca_elitehorses,"onXca_elitehorses"],[SYSTEM_XWX_ELITEHORSES,"ActionMenu_xwx_elitehorses",EmbeddedArt.hud_xwx_elitehorses,"onXwx_elitehorses"],[SYSTEM_XHX_ELITEHORSES,"ActionMenu_xhx_elitehorses",EmbeddedArt.hud_xhx_elitehorses,"onXhx_elitehorses"],[SYSTEM_XIS_ELITEHORSES,"ActionMenu_xis_elitehorses",EmbeddedArt.hud_xis_elitehorses
      ,"onXis_elitehorses"],[SYSTEM_XNF_ELITEHORSES,"ActionMenu_xnf_elitehorses",EmbeddedArt.hud_xnf_elitehorses,"onXnf_elitehorses"],[SYSTEM_XRU_ELITEHORSES,"ActionMenu_xru_elitehorses",EmbeddedArt.hud_xru_elitehorses,"onXru_elitehorses"],[SYSTEM_XCB_ELITEHORSES,"ActionMenu_xcb_elitehorses",EmbeddedArt.hud_xcb_elitehorses,"onXcb_elitehorses"],[SYSTEM_XDV_ELITEHORSES,"ActionMenu_xdv_elitehorses",EmbeddedArt.hud_xdv_elitehorses,"onXdv_elitehorses"],[SYSTEM_XTY_ELITEHORSES,"ActionMenu_xty_elitehorses",EmbeddedArt.hud_xty_elitehorses,"onXty_elitehorses"],[SYSTEM_XFW_ELITEHORSES,"ActionMenu_xfw_elitehorses",EmbeddedArt.hud_xfw_elitehorses,"onXfw_elitehorses"],[SYSTEM_XHA_ELITEHORSES,"ActionMenu_xha_elitehorses",EmbeddedArt.hud_xha_elitehorses,"onXha_elitehorses"],[SYSTEM_XBR_ELITEHORSES,"ActionMenu_xbr_elitehorses",EmbeddedArt.hud_xbr_elitehorses,"onXbr_elitehorses"],[SYSTEM_XFE_ELITEHORSES,"ActionMenu_xfe_elitehorses",EmbeddedArt.hud_xfe_elitehorses,"onXfe_elitehorses"],[SYSTEM_XDW_ELITEHORSES,"ActionMenu_xdw_elitehorses"
      ,EmbeddedArt.hud_xdw_elitehorses,"onXdw_elitehorses"],[SYSTEM_XTI_ELITEHORSES,"ActionMenu_xti_elitehorses",EmbeddedArt.hud_xti_elitehorses,"onXti_elitehorses"],[SYSTEM_XUW_ELITEHORSES,"ActionMenu_xuw_elitehorses",EmbeddedArt.hud_xuw_elitehorses,"onXuw_elitehorses"],[SYSTEM_XHH_ELITEHORSES,"ActionMenu_xhh_elitehorses",EmbeddedArt.hud_xhh_elitehorses,"onXhh_elitehorses"],[SYSTEM_XCH_ELITEHORSES,"ActionMenu_xch_elitehorses",EmbeddedArt.hud_xch_elitehorses,"onXch_elitehorses"],[SYSTEM_XBO_ELITEHORSES,"ActionMenu_xbo_elitehorses",EmbeddedArt.hud_xbo_elitehorses,"onXbo_elitehorses"],[SYSTEM_XMO_ELITEHORSES,"ActionMenu_xmo_elitehorses",EmbeddedArt.hud_xmo_elitehorses,"onXmo_elitehorses"],[SYSTEM_XJM_ELITEHORSES,"ActionMenu_xjm_elitehorses",EmbeddedArt.hud_xjm_elitehorses,"onXjm_elitehorses"],[SYSTEM_XJP_ELITEHORSES_MS,"ActionMenu_xjp_elitehorses_ms",EmbeddedArt.hud_xjp_elitehorses_ms,"onXjp_elitehorses_ms"],[SYSTEM_XJP_ELITEHORSES,"ActionMenu_xjp_elitehorses",EmbeddedArt.hud_xjp_elitehorses,"onXjp_elitehorses"]
      ,[SYSTEM_XIN_ELITEHORSES,"ActionMenu_xin_elitehorses",EmbeddedArt.hud_xin_elitehorses,"onXin_elitehorses"],[SYSTEM_XWI_ELITEHORSES,"ActionMenu_xwi_elitehorses",EmbeddedArt.hud_xwi_elitehorses,"onXwi_elitehorses"],[SYSTEM_XTR_ELITEHORSES,"ActionMenu_xtr_elitehorses",EmbeddedArt.hud_xtr_elitehorses,"onXtr_elitehorses"],[SYSTEM_SAVANNAHRESERVE,"ActionMenu_savannahreserve",EmbeddedArt.hud_savannahreserve,"onSavannahreserve"]];
      
      private var m_currentContentsWindow:FeatureCraftingContentsWindow;
      
      private var m_currentNPCWindow:FeatureCraftingNPCWindow;
      
      private var m_name:String;
      
      private var m_friendlyTitle:String;
      
      private var m_pointsFriendlyTitle:String;
      
      private var m_prereqs:Array;
      
      private var m_assets:Object;
      
      private var m_goods:Array;
      
      private var m_inventories:Array;
      
      private var m_stations:Array;
      
      private var m_recipes:Array;
      
      private var m_npcs:Array;
      
      private var m_levels:Array;
      
      private var m_infiniteLevelIncrement:int;
      
      private var m_infiniteLevelCoins:int;
      
      private var m_infiniteLevelXP:int;
      
      private var m_npcCharacterImages:Array;
      
      private var m_orderBoards:Object;
      
      private var m_points:int;
      
      private var m_npcData:Object;
      
      private var m_unlockCostK:Number;
      
      private var m_unlockCostM:Number;
      
      private var m_supportMultipleOrderboards:Boolean = false;
      
      public var m_buildingName:String;
      
      private var m_showEmptyUnlockPopup:Boolean;
      
      private var m_buyGoodMultiplier:Number;
      
      private var m_useAutoScaling:Boolean;
      
      private var m_location:String = "";
      
      private var m_bonusAnimal:String = "";
      
      private var m_whatisThisPrefix:String = "";
      
      public function FeatureCraftingSystem(config:XML)
      {
         var assetXml:XML = null;
         var goodsXml:XMLList = null;
         var goods:Array = null;
         var goodXml:XML = null;
         var inventoriesXml:XMLList = null;
         var inventories:Array = null;
         var inventoryXml:XML = null;
         var levelsXml:XMLList = null;
         var levels:Array = null;
         var levelXml:XML = null;
         var stationsXml:XMLList = null;
         var stations:Array = null;
         var stationXml:XML = null;
         var recipesXml:XMLList = null;
         var recipes:Array = null;
         var recipeXml:XML = null;
         var npcsXml:XMLList = null;
         var npcs:Array = null;
         var npcXml:XML = null;
         var npcCharactersXml:XMLList = null;
         var characterImages:Array = null;
         var npcCharacterXml:XML = null;
         var assetName:String = null;
         var assetUrl:String = null;
         super();
         this.m_name = config.@name;
         this.m_buildingName = config.@buildingName;
         if(config.hasOwnProperty("@location"))
         {
            this.m_location = config.@location;
         }
         if(config.hasOwnProperty("@whatisThisPrefix"))
         {
            this.m_whatisThisPrefix = config.@whatisThisPrefix;
         }
         if(config.hasOwnProperty("@bonusAnimal"))
         {
            this.m_bonusAnimal = config.@bonusAnimal;
         }
         this.m_showEmptyUnlockPopup = this.m_name != FeatureCraftingSystem.SYSTEM_HORSE_CRAFTING && this.m_name != FeatureCraftingSystem.SYSTEM_HOLLYBRIGHT_PARK && this.m_name != FeatureCraftingSystem.SYSTEM_JUNGLE_HIDEAWAY && this.m_name != FeatureCraftingSystem.SYSTEM_TINMAN_FOUNTAIN && this.m_name != FeatureCraftingSystem.SYSTEM_AZURE_EMPORIUM && this.m_name != FeatureCraftingSystem.SYSTEM_ARABIAN_STALLIONS && this.m_name != FeatureCraftingSystem.SYSTEM_MAGICGARDEN && this.m_name != FeatureCraftingSystem.SYSTEM_BLACKJACKBARN && this.m_name != FeatureCraftingSystem.SYSTEM_TOYSHOPPE && this.m_name != FeatureCraftingSystem.SYSTEM_FORESTFAIR && this.m_name != FeatureCraftingSystem.SYSTEM_ROYALSTABLE && (this.m_name != FeatureCraftingSystem.SYSTEM_RODEORANCH && this.m_name != FeatureCraftingSystem.SYSTEM_TIDEHOMESTEAD && this.m_name != FeatureCraftingSystem.SYSTEM_SAVANNAHRESERVE && this.m_name != FeatureCraftingSystem.SYSTEM_XTR_ELITEHORSES) && this.m_name != FeatureCraftingSystem.SYSTEM_XWI_ELITEHORSES && this
         .m_name != FeatureCraftingSystem.SYSTEM_XIN_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES_MS && this.m_name != FeatureCraftingSystem.SYSTEM_XJM_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XMO_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XBO_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XCH_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XHH_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XTI_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XDW_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XFE_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XHH_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XUW_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XBR_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XHA_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XFW_ELITEHORSES && this
         .m_name != FeatureCraftingSystem.SYSTEM_XTY_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XDV_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XCB_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XRU_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XNF_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XIS_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XHX_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XWX_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XCA_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XBL_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XRT_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XSU_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XCL_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XID_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XHF_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XWS_ELITEHORSES && this
         .m_name != FeatureCraftingSystem.SYSTEM_XFS_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XMT_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XBB_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XDM_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XCD_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XAH_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XPU_ELITEHORSES && this.m_name != FeatureCraftingSystem.SYSTEM_XYT_ELITEHORSES;
         this.m_supportMultipleOrderboards = config.hasOwnProperty("@multipleOrderBoards") ? Boolean(config.@multipleOrderBoards) : false;
         this.m_buyGoodMultiplier = config.hasOwnProperty("@buyGoodMultiplier") ? parseFloat(config.@buyGoodMultiplier) : GOOD_COST_MULTIPLIER;
         this.m_unlockCostK = parseFloat(config.@unlockCostK.toString());
         this.m_unlockCostM = parseFloat(config.@unlockCostM.toString());
         if(config.hasOwnProperty("@useAutoScaling") && config.@useAutoScaling == "true")
         {
            this.m_useAutoScaling = true;
         }
         else
         {
            this.m_useAutoScaling = false;
         }
         if(config.hasOwnProperty("prereqs"))
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(config.prereqs.children());
         }
         var assets:Object = {};
         var assetsXml:XMLList = config.assets.asset;
         for each(assetXml in assetsXml)
         {
            assetName = assetXml.@name.toString();
            assetUrl = assetXml.@url.toString();
            assets[assetName] = assetUrl;
         }
         this.m_assets = assets;
         goodsXml = config.goods.good;
         goods = [];
         for each(goodXml in goodsXml)
         {
            goods.push(new FeatureCraftingGood(this,goodXml));
         }
         this.m_goods = goods;
         inventoriesXml = config.storages.storage;
         inventories = [];
         for each(inventoryXml in inventoriesXml)
         {
            inventories.push(new FeatureCraftingInventory(this,inventoryXml));
         }
         this.m_inventories = inventories;
         levelsXml = config.levels.level;
         levels = [];
         for each(levelXml in levelsXml)
         {
            levels.push(new FeatureCraftingLevel(this,levelXml));
         }
         levels.sortOn("levelNum",Array.NUMERIC);
         this.m_levels = levels;
         this.m_infiniteLevelIncrement = parseInt(config.levels.@infiniteIncrement);
         this.m_infiniteLevelCoins = parseInt(config.levels.@infiniteCoins);
         this.m_infiniteLevelXP = parseInt(config.levels.@infiniteXp);
         stationsXml = config.stations.station;
         stations = [];
         for each(stationXml in stationsXml)
         {
            stations.push(new FeatureCraftingStation(this,stationXml));
         }
         this.m_stations = stations;
         recipesXml = config.recipes.recipe;
         recipes = [];
         for each(recipeXml in recipesXml)
         {
            recipes.push(new FeatureCraftingRecipe(this,recipeXml));
         }
         this.m_recipes = recipes;
         npcsXml = config.npcs.npc;
         npcs = [];
         for each(npcXml in npcsXml)
         {
            npcs.push(new FeatureCraftingNPC(this,npcXml));
         }
         this.m_npcs = npcs;
         npcCharactersXml = config.npcCharacters.npcCharacter;
         characterImages = [];
         for each(npcCharacterXml in npcCharactersXml)
         {
            characterImages.push(npcCharacterXml.toString());
         }
         this.m_npcCharacterImages = characterImages;
         this.initUserData();
         FeatureCraftingManager.instance.dispatchEvent(new DynamicObjectEvent(FeatureCraftingManager.EVENT_LEVEL_CHANGE,this));
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.refreshFeatureOptions);
      }
      
      private function refreshFeatureOptions(e:Event) : void
      {
         var inventory:FeatureCraftingInventory = null;
         var data:Object = this.getUserData();
         if(data)
         {
            for each(inventory in this.m_inventories)
            {
               if(data[DATAKEY_STORAGE][inventory.name])
               {
                  inventory.setUserData(data[DATAKEY_STORAGE][inventory.name]);
               }
            }
         }
      }
      
      private function initUserData() : void
      {
         var good:FeatureCraftingGood = null;
         var inventory:FeatureCraftingInventory = null;
         var station:FeatureCraftingStation = null;
         var recipe:FeatureCraftingRecipe = null;
         var npcName:String = null;
         var orderBoard:FeatureCraftingOrderBoard = null;
         var data:Object = this.getUserData();
         if(data)
         {
            for each(good in this.m_goods)
            {
               if(data[DATAKEY_GOODS][good.name])
               {
                  good.setUserData(data[DATAKEY_GOODS][good.name]);
               }
            }
            for each(inventory in this.m_inventories)
            {
               if(data[DATAKEY_STORAGE][inventory.name])
               {
                  inventory.setUserData(data[DATAKEY_STORAGE][inventory.name]);
               }
            }
            this.m_orderBoards = {};
            if(this.m_supportMultipleOrderboards)
            {
               for(npcName in data[DATAKEY_ORDERBOARD])
               {
                  this.m_orderBoards[npcName] = new FeatureCraftingOrderBoard(this,data[DATAKEY_ORDERBOARD][npcName]);
                  this.m_orderBoards[npcName].npcName = npcName;
               }
            }
            else
            {
               orderBoard = new FeatureCraftingOrderBoard(this,data[DATAKEY_ORDERBOARD]);
               this.m_orderBoards[orderBoard.npcName] = orderBoard;
            }
            for each(station in this.m_stations)
            {
               if(data[DATAKEY_STATIONS][station.name])
               {
                  station.setUserData(data[DATAKEY_STATIONS][station.name]);
               }
            }
            for each(recipe in this.m_recipes)
            {
               if(data[DATAKEY_MASTERY][recipe.name])
               {
                  recipe.setUserData(data[DATAKEY_MASTERY][recipe.name]);
               }
            }
            this.m_points = data.hasOwnProperty(DATAKEY_POINTS) ? int(parseInt(data[DATAKEY_POINTS])) : 0;
            this.m_npcData = data.hasOwnProperty(DATAKEY_NPCS) ? data[DATAKEY_NPCS] : {};
         }
      }
      
      public function getUserData() : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureCraftingManager.FEATURE_NAME,this.m_name);
         if(!data)
         {
            data = this.createFeatureData();
         }
         return data;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get friendlyTitle() : String
      {
         if(!this.m_friendlyTitle)
         {
            this.m_friendlyTitle = this.getLocalizedString("System_" + this.m_name);
         }
         return this.m_friendlyTitle;
      }
      
      public function get currentContentsWindow() : FeatureCraftingContentsWindow
      {
         return this.m_currentContentsWindow;
      }
      
      public function set currentContentsWindow(value:FeatureCraftingContentsWindow) : void
      {
         this.m_currentContentsWindow = value;
      }
      
      public function get currentNPCWindow() : FeatureCraftingNPCWindow
      {
         return this.m_currentNPCWindow;
      }
      
      public function set currentNPCWindow(value:FeatureCraftingNPCWindow) : void
      {
         this.m_currentNPCWindow = value;
      }
      
      public function arePrerequisitesMet() : Boolean
      {
         return !this.m_prereqs || PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
      }
      
      public function getAssetUrl(assetName:String) : String
      {
         var result:String = null;
         if(Boolean(this.m_assets) && Boolean(this.m_assets[assetName]))
         {
            result = this.m_assets[assetName];
         }
         else
         {
            GlobalEngine.assert(false,"Dialog not found for " + this.m_name + ":" + assetName + ".");
         }
         return result;
      }
      
      public function getOrderBoard(npcName:String = "none") : FeatureCraftingOrderBoard
      {
         var result:FeatureCraftingOrderBoard = null;
         if(Boolean(this.m_orderBoards) && this.m_orderBoards.hasOwnProperty(npcName))
         {
            result = this.m_orderBoards[npcName];
         }
         return result;
      }
      
      public function unlockOrderBoard(npcName:String, data:Object) : void
      {
         var ob:FeatureCraftingOrderBoard = new FeatureCraftingOrderBoard(this,data);
         ob.npcName = npcName;
         this.m_orderBoards[npcName] = ob;
         if(!this.m_npcData.hasOwnProperty(npcName))
         {
            this.m_npcData[npcName] = {};
         }
         this.m_npcData[npcName]["unlocked"] = true;
      }
      
      public function getStations() : Array
      {
         return this.m_stations;
      }
      
      public function getStation(stationName:String) : FeatureCraftingStation
      {
         var result:FeatureCraftingStation = null;
         var station:FeatureCraftingStation = null;
         for each(station in this.m_stations)
         {
            if(station.name == stationName)
            {
               result = station;
               break;
            }
         }
         return result;
      }
      
      public function getStationThatMakesRecipe(recipeName:String) : FeatureCraftingStation
      {
         var result:FeatureCraftingStation = null;
         var station:FeatureCraftingStation = null;
         var recipeNames:Array = null;
         for each(station in this.m_stations)
         {
            recipeNames = station.getAllRecipeNames();
            if(recipeNames.indexOf(recipeName) >= 0)
            {
               result = station;
               break;
            }
         }
         return result;
      }
      
      public function getStationsThatAreReady() : Array
      {
         var station:FeatureCraftingStation = null;
         var result:Array = [];
         var stations:Array = this.getStations();
         if(stations)
         {
            for each(station in stations)
            {
               if(station.isReady())
               {
                  result.push(station);
               }
            }
         }
         return result;
      }
      
      public function getHighestPriorityRecipeThatIsReady() : FeatureCraftingRecipe
      {
         var result:FeatureCraftingRecipe = null;
         var station:FeatureCraftingStation = null;
         var currentRecipe:FeatureCraftingRecipe = null;
         var stations:Array = this.getStationsThatAreReady();
         if(stations)
         {
            for each(station in stations)
            {
               if(!station.autoStart)
               {
                  currentRecipe = this.getRecipe(station.currentRecipeName());
                  if(!result || currentRecipe.finishTime >= result.finishTime)
                  {
                     result = currentRecipe;
                  }
               }
            }
         }
         return result;
      }
      
      public function getUnlocks(startingLevel:int, endingLevel:int) : Array
      {
         var unlockLevel:int = 0;
         var recipe:FeatureCraftingRecipe = null;
         var station:FeatureCraftingStation = null;
         var npc:FeatureCraftingNPC = null;
         var result:Array = [];
         var recipes:Array = this.getRecipes();
         if(recipes)
         {
            for each(recipe in recipes)
            {
               unlockLevel = recipe.unlockLevel;
               if(unlockLevel > startingLevel && unlockLevel <= endingLevel)
               {
                  result.unshift(recipe);
               }
            }
         }
         var stations:Array = this.getStations();
         if(stations)
         {
            for each(station in stations)
            {
               unlockLevel = station.unlockLevel;
               if(unlockLevel > startingLevel && unlockLevel <= endingLevel)
               {
                  result.unshift(station);
               }
            }
         }
         var npcs:Array = this.getNPCs();
         if(npcs)
         {
            for each(npc in npcs)
            {
               unlockLevel = npc.unlockLevel;
               if(unlockLevel > startingLevel && unlockLevel <= endingLevel && !npc.paidUnlocked)
               {
                  result.unshift(npc);
               }
            }
         }
         return result;
      }
      
      public function getUnlockCost(unlockPointCount:int) : int
      {
         var pointsNeeded:int = unlockPointCount - this.points;
         return int(Math.round(this.m_unlockCostK * Math.pow(pointsNeeded,this.m_unlockCostM)));
      }
      
      public function grantRewards(rewards:Array) : void
      {
         var reward:Object = null;
         var rewardAmount:int = 0;
         var part:FeatureCraftingInventoryPart = null;
         for each(reward in rewards)
         {
            switch(reward[REWARDS_TYPE])
            {
               case REWARDS_TYPE_COIN:
                  Global.player.gold += parseInt(reward[REWARDS_AMOUNT]);
                  break;
               case REWARDS_TYPE_POINTS:
                  this.incrementPointCount(parseInt(reward[REWARDS_AMOUNT]));
                  break;
               case REWARDS_TYPE_ITEMGRANT:
                  rewardAmount = 1;
                  if(reward[REWARDS_AMOUNT] != null && reward[REWARDS_AMOUNT] != "")
                  {
                     rewardAmount = parseInt(reward[REWARDS_AMOUNT]);
                  }
                  Global.player.addGift(reward[REWARDS_VALUE],"0",rewardAmount);
                  break;
               case REWARDS_TYPE_INVENTORYPARTS:
                  part = this.getInventoryPart(reward[REWARDS_VALUE]);
                  part.incrementQuantity(reward[REWARDS_AMOUNT]);
            }
         }
      }
      
      public function getInventoryPart(inventoryPart:String) : FeatureCraftingInventoryPart
      {
         var inventory:FeatureCraftingInventory = null;
         var part:FeatureCraftingInventoryPart = null;
         var result:FeatureCraftingInventoryPart = null;
         var inventories:Array = this.getInventories();
         for each(inventory in inventories)
         {
            for each(part in inventory.parts())
            {
               if(part.name == inventoryPart)
               {
                  result = part;
                  break;
               }
            }
            if(result != null)
            {
               break;
            }
         }
         return result;
      }
      
      public function evaluateServerResponseForNewOrders(response:Object) : void
      {
         var orderBoard:FeatureCraftingOrderBoard = null;
         var npcName:String = null;
         if(Boolean(response) && response.hasOwnProperty(DATAKEY_ORDERBOARD))
         {
            for(npcName in response[DATAKEY_ORDERBOARD])
            {
               orderBoard = new FeatureCraftingOrderBoard(this,response[DATAKEY_ORDERBOARD][npcName]);
               orderBoard.npcName = npcName;
               this.m_orderBoards[orderBoard.npcName] = orderBoard;
            }
            if(this.currentContentsWindow)
            {
               this.currentContentsWindow.refreshOrders();
               this.currentContentsWindow.hideLoadingWidget();
            }
            FeatureCraftingManager.instance.dispatchEvent(new DynamicObjectEvent(FeatureCraftingManager.EVENT_NEW_ORDER_BOARD,this));
         }
      }
      
      public function getNPCs() : Array
      {
         return this.m_npcs;
      }
      
      public function getRecipes() : Array
      {
         return this.m_recipes;
      }
      
      public function getRecipe(recipeName:String) : FeatureCraftingRecipe
      {
         var recipe:FeatureCraftingRecipe = null;
         var result:FeatureCraftingRecipe = null;
         for each(recipe in this.m_recipes)
         {
            if(recipe.name == recipeName)
            {
               result = recipe;
               break;
            }
         }
         return result;
      }
      
      public function getRecipesGivenRecipeNames(recipeNames:Array) : Array
      {
         var recipe:FeatureCraftingRecipe = null;
         var result:Array = [];
         for each(recipe in this.m_recipes)
         {
            if(recipeNames.indexOf(recipe.name) >= 0)
            {
               result.push(recipe);
            }
         }
         return result;
      }
      
      public function getAutoScaling() : Boolean
      {
         return this.m_useAutoScaling;
      }
      
      public function getInventories() : Array
      {
         return this.m_inventories;
      }
      
      public function getInventory(inventoryName:String) : FeatureCraftingInventory
      {
         var inventory:FeatureCraftingInventory = null;
         var result:FeatureCraftingInventory = null;
         for each(inventory in this.m_inventories)
         {
            if(inventory.name == inventoryName)
            {
               result = inventory;
               break;
            }
         }
         return result;
      }
      
      public function getGoodsForInventory(inventoryName:String) : Array
      {
         var good:FeatureCraftingGood = null;
         var result:Array = [];
         for each(good in this.m_goods)
         {
            if(good.storageName == inventoryName && good.inventoryCount > 0)
            {
               result.push(good);
            }
         }
         return result;
      }
      
      public function getGoodsByNames(goodNames:Array) : Array
      {
         var good:FeatureCraftingGood = null;
         var result:Array = [];
         for each(good in this.m_goods)
         {
            if(goodNames.indexOf(good.name) != -1)
            {
               result.push(good);
            }
         }
         return result;
      }
      
      public function getGoodByName(goodName:String) : FeatureCraftingGood
      {
         var result:FeatureCraftingGood = null;
         var good:FeatureCraftingGood = null;
         for each(good in this.m_goods)
         {
            if(goodName == good.name)
            {
               result = good;
               break;
            }
         }
         GlobalEngine.assert(result != null,"Could not find goodName: " + goodName);
         return result;
      }
      
      public function getNPCCharacterImages() : Array
      {
         return this.m_npcCharacterImages;
      }
      
      public function get points() : int
      {
         return this.m_points;
      }
      
      public function get npcData() : Object
      {
         return this.m_npcData;
      }
      
      public function adminSetPoints(points:int) : void
      {
         this.m_points = points;
      }
      
      public function incrementPointCount(amount:int) : void
      {
         var minInventoryCounts:Object = null;
         var inventoryName:String = null;
         var coinReward:int = 0;
         var xpReward:int = 0;
         var levels:Array = null;
         var i:int = 0;
         var lastDefinedLevel:FeatureCraftingLevel = null;
         var unlocks:Array = null;
         var level:FeatureCraftingLevel = null;
         var levelMinInventoryCounts:Object = null;
         var infiniteCoins:int = 0;
         var infiniteXP:int = 0;
         var infiniteStartingLevel:int = 0;
         var inventory:FeatureCraftingInventory = null;
         var startingLevel:int = this.getPointLevel();
         this.m_points += amount;
         var endingLevel:int = this.getPointLevel();
         if(startingLevel < endingLevel)
         {
            minInventoryCounts = {};
            levels = this.m_levels;
            i = startingLevel;
            while(i < endingLevel && i < levels.length)
            {
               level = levels[i];
               coinReward += level.coinReward;
               xpReward += level.xpReward;
               levelMinInventoryCounts = level.minInventoryCounts;
               for(inventoryName in levelMinInventoryCounts)
               {
                  if(minInventoryCounts.hasOwnProperty(inventoryName))
                  {
                     minInventoryCounts[inventoryName] = Math.max(minInventoryCounts[inventoryName],levelMinInventoryCounts[inventoryName]);
                  }
                  else
                  {
                     minInventoryCounts[inventoryName] = levelMinInventoryCounts[inventoryName];
                  }
               }
               i++;
            }
            lastDefinedLevel = levels[levels.length - 1];
            if(lastDefinedLevel.levelNum < endingLevel)
            {
               infiniteCoins = this.m_infiniteLevelCoins;
               infiniteXP = this.m_infiniteLevelXP;
               infiniteStartingLevel = Math.max(startingLevel,lastDefinedLevel.levelNum);
               coinReward += (endingLevel - infiniteStartingLevel) * infiniteCoins;
               xpReward += (endingLevel - infiniteStartingLevel) * infiniteXP;
            }
            if(coinReward > 0)
            {
               Global.player.gold += coinReward;
            }
            if(xpReward > 0)
            {
               Global.player.xp += xpReward;
            }
            for(inventoryName in minInventoryCounts)
            {
               inventory = this.getInventory(inventoryName);
               if(inventory)
               {
                  inventory.setMinCapacity(minInventoryCounts[inventoryName]);
               }
            }
            if(this.m_currentContentsWindow)
            {
               this.m_currentContentsWindow.refresh();
            }
            unlocks = this.getUnlocks(startingLevel,endingLevel);
            if(this.m_showEmptyUnlockPopup || unlocks.length > 0 && startingLevel >= 1 && (unlocks[0].prereqName == "" || PrerequisiteUtility.checkPrereqByName(unlocks[0].prereqName)))
            {
               FeatureCraftingLevelUpWindow.display(this,coinReward,xpReward,unlocks);
            }
            FeatureCraftingManager.instance.dispatchEvent(new DynamicObjectEvent(FeatureCraftingManager.EVENT_LEVEL_CHANGE,this));
         }
         else if(this.m_currentContentsWindow)
         {
            this.m_currentContentsWindow.refreshPoints();
         }
      }
      
      public function refreshCurrentWindow() : void
      {
         if(this.m_currentContentsWindow)
         {
            this.m_currentContentsWindow.refresh();
         }
      }
      
      public function getPointsFriendlyTitle() : String
      {
         if(!this.m_pointsFriendlyTitle)
         {
            this.m_pointsFriendlyTitle = this.getLocalizedString("Points_" + this.m_name);
         }
         return this.m_pointsFriendlyTitle;
      }
      
      public function getPointLevelFromPointCount(points:int) : int
      {
         var foundHigherDefinedLevel:Boolean = false;
         var level:FeatureCraftingLevel = null;
         var infiniteLevelIncrement:int = 0;
         var lastDefinedLevel:FeatureCraftingLevel = null;
         var result:int = 1;
         if(points > 0)
         {
            foundHigherDefinedLevel = false;
            for each(level in this.m_levels)
            {
               if(level.pointsRequired > points)
               {
                  foundHigherDefinedLevel = true;
                  break;
               }
               result = level.levelNum;
            }
            if(!foundHigherDefinedLevel)
            {
               infiniteLevelIncrement = this.m_infiniteLevelIncrement;
               lastDefinedLevel = this.m_levels[this.m_levels.length - 1];
               points -= lastDefinedLevel.pointsRequired;
               result = lastDefinedLevel.levelNum + Math.floor(points / infiniteLevelIncrement);
            }
         }
         return result;
      }
      
      public function completeOrderBoard(ob:FeatureCraftingOrderBoard) : void
      {
         var prevLevel:int = 0;
         var prevNpcData:Object = null;
         var animalObject:Object = null;
         var level:int = 0;
         var npcData:Object = null;
         if(ob.npcName != FeatureCraftingSystem.DEFAULT_NPC_NAME)
         {
            if(!this.m_npcData.hasOwnProperty(ob.npcName))
            {
               this.m_npcData[ob.npcName] = {};
            }
            prevLevel = 0;
            prevNpcData = this.m_npcData;
            for each(animalObject in prevNpcData)
            {
               if(animalObject.hasOwnProperty("complete"))
               {
                  if(animalObject["complete"] == true)
                  {
                     prevLevel++;
                  }
               }
            }
            this.m_npcData[ob.npcName].complete = true;
            level = 0;
            npcData = this.m_npcData;
            for each(animalObject in npcData)
            {
               if(animalObject.hasOwnProperty("complete"))
               {
                  if(animalObject["complete"] == true)
                  {
                     level++;
                  }
               }
            }
            if(level > prevLevel && this.getNPCs().length == level)
            {
               if(ob.system.m_name == OlyInnovationManager.ELITEHORSES_BUILDING)
               {
                  GlobalEventManager.getInstance().dispatchEvent(new Event(OlyInnovationManager.EVENT_EH_COMPLETE));
               }
               GlobalEventManager.getInstance().dispatchEvent(new SuperBuildingCompleteEvent(SuperBuildingCompleteEvent.BUILDING_COMPLETED,{"name":ob.system.m_name}));
            }
         }
      }
      
      public function getPointLevel() : int
      {
         return this.getPointLevelFromPointCount(this.m_points);
      }
      
      public function getPointsNeededForGivenLevel(level:int) : int
      {
         var lastDefinedLevel:FeatureCraftingLevel = null;
         var result:int = 0;
         if(level > 0)
         {
            if(level <= this.m_levels.length)
            {
               result = (this.m_levels[level - 1] as FeatureCraftingLevel).pointsRequired;
            }
            else
            {
               lastDefinedLevel = this.m_levels[this.m_levels.length - 1] as FeatureCraftingLevel;
               result = lastDefinedLevel.pointsRequired + (level - lastDefinedLevel.levelNum) * this.m_infiniteLevelIncrement;
            }
         }
         return result;
      }
      
      public function getLocalizedString(key:String, params:Object = null) : String
      {
         var result:String = "";
         var systemKey:String = key + "_" + this.m_name;
         if(ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,systemKey))
         {
            result = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,systemKey,params);
         }
         else if(ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,key))
         {
            result = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,key,params);
         }
         else
         {
            result = key;
         }
         return result;
      }
      
      public function speedUpCostMultiplier() : Number
      {
         return HARVEST_NOW_MULTIPLIER;
      }
      
      public function purchaseGoodCostMultiplier() : Number
      {
         return this.m_buyGoodMultiplier;
      }
      
      public function createFeatureData() : Object
      {
         var data:Object = new Object();
         switch(this.m_name)
         {
            case SYSTEM_DAIRY_CRAFTING:
               data[DATAKEY_STORAGE] = {
                  "barn":{"level":1},
                  "silo":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {
                  "orders":[{
                     "goods":{"butter":1},
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":5
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":20
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"milkshaketree",
                     "amount":1
                  }]
               };
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "milk":{
                     "active":true,
                     "startTime":0,
                     "recipe":"milk"
                  },
                  "butter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"butter"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               break;
            case SYSTEM_HORSE_CRAFTING:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":2},
                  "recipe":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"horse1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "meal":2,
                        "waterTrough":2,
                        "hayBundle":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_crates",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"horse_rodeobronco",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "waterPump":{
                     "active":true,
                     "startTime":0,
                     "recipe":"waterPail"
                  },
                  "feedWagon":{
                     "active":true,
                     "startTime":0,
                     "recipe":"meal"
                  },
                  "horseGroom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"groomingKit"
                  },
                  "fabricRoll":{
                     "active":true,
                     "startTime":0,
                     "recipe":"fabric"
                  },
                  "pleatherStand":{
                     "active":true,
                     "startTime":0,
                     "recipe":"pleather"
                  },
                  "farrierForge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"metal"
                  },
                  "corral":{
                     "active":true,
                     "startTime":0,
                     "recipe":"rank"
                  },
                  "waterShed":{
                     "active":true,
                     "startTime":0,
                     "recipe":"waterTrough"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"horse1":{"complete":false}};
               break;
            case SYSTEM_YARN_BARN:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":1},
                  "recipe":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {
                  "orders":[{
                     "goods":{"woolYarn":1},
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":5
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":20
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"yarnballtree",
                     "amount":1
                  }]
               };
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "sheep":{
                     "active":true,
                     "startTime":0,
                     "recipe":"merinoFleece"
                  },
                  "carder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"woolYarn"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               break;
            case SYSTEM_SWEET_SHOP:
               data[DATAKEY_STORAGE] = {
                  "candyCounter":{"level":1},
                  "sodaFountain":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {
                  "orders":[{
                     "goods":{"confectionerssugar":1},
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":5
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":20
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"eggcreamtree",
                     "amount":1
                  }]
               };
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "sugarsupply":{
                     "active":true,
                     "startTime":0,
                     "recipe":"rawsugar"
                  },
                  "sugarprocesser":{
                     "active":true,
                     "startTime":0,
                     "recipe":"confectionerssugar"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               break;
            case SYSTEM_APOTHECARY:
               data[DATAKEY_STORAGE] = {
                  "potionCabinet":{"level":1},
                  "ingredientCupboard":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {
                  "orders":[{
                     "goods":{"bluebubblebrew":1},
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":5
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":20
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"owlwatchtree",
                     "amount":1
                  }]
               };
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "brewingcauldron":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bottledtonic"
                  },
                  "dragonbrewer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bluebubblebrew"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               break;
            case SYSTEM_HOLLYBRIGHT_PARK:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":2},
                  "recipe":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"animal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "holidayfeed":2,
                        "sparklewaterbottle":2,
                        "hollybrightcookietreat":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_sparklespackle",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"elk_xhl_curled",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "sparklewaterpump":{
                     "active":true,
                     "startTime":0,
                     "recipe":"sparklewaterbucket"
                  },
                  "holidaywheelbarrow":{
                     "active":true,
                     "startTime":0,
                     "recipe":"holidayfeed"
                  },
                  "animaltoychest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"enrichmenttoys"
                  },
                  "trainingpen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"goldstars"
                  },
                  "wintermagic":{
                     "active":true,
                     "startTime":0,
                     "recipe":"wintermagicwand"
                  },
                  "spiritofseason":{
                     "active":true,
                     "startTime":0,
                     "recipe":"givingbasket"
                  },
                  "lightfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"holidaylight"
                  },
                  "waterenclosure":{
                     "active":true,
                     "startTime":0,
                     "recipe":"sparklewaterbottle"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"animal1":{"complete":false}};
               break;
            case SYSTEM_JUNGLE_HIDEAWAY:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":2},
                  "recipe":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"forestAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "wildfruit":2,
                        "waterbowl":2,
                        "mysterytreat":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_grassbed",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"peacock_legendaryredstlits",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "wateringhole":{
                     "active":true,
                     "startTime":0,
                     "recipe":"waterleaf"
                  },
                  "wildfruittree":{
                     "active":true,
                     "startTime":0,
                     "recipe":"wildfruit"
                  },
                  "feathernest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"exoticfeather"
                  },
                  "pestleandmortar":{
                     "active":true,
                     "startTime":0,
                     "recipe":"paintbowl"
                  },
                  "fabricweaver":{
                     "active":true,
                     "startTime":0,
                     "recipe":"traditionalcloth"
                  },
                  "goldmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"golddust"
                  },
                  "buriedtreasure":{
                     "active":true,
                     "startTime":0,
                     "recipe":"hiddenjewels"
                  },
                  "waterfall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"waterbowl"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"forestAnimal1":{"complete":false}};
               break;
            case SYSTEM_TINMAN_FOUNTAIN:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":2},
                  "recipe":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"emeraldAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "magicfeed":2,
                        "smalldrinkingbowl":2,
                        "emeraldcitylollipop":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_yellowbrick",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"bigcat_goldenwingedcub",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "enchantmentpool":{
                     "active":true,
                     "startTime":0,
                     "recipe":"enchantedwater"
                  },
                  "feedingstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"magicfeed"
                  },
                  "winkierookery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"enchantedeggs"
                  },
                  "spellbook":{
                     "active":true,
                     "startTime":0,
                     "recipe":"magicspells"
                  },
                  "trainingaerie":{
                     "active":true,
                     "startTime":0,
                     "recipe":"ridinghalter"
                  },
                  "caringpen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"heartmedallion"
                  },
                  "adoptionpen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"adoptionpapers"
                  },
                  "waterenclosure":{
                     "active":true,
                     "startTime":0,
                     "recipe":"smalldrinkingbowl"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"emeraldAnimal1":{"complete":false}};
               break;
            case SYSTEM_AZURE_EMPORIUM:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":2},
                  "recipe":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"mediterraneanAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "bazarfeed":2,
                        "smallfountaincup":2,
                        "bazaartreats":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_tentpole",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xmd_rampantgryphon",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "waterfountain":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bazaarwater"
                  },
                  "feedingtrough":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bazarfeed"
                  },
                  "masonryblock":{
                     "active":true,
                     "startTime":0,
                     "recipe":"polishedstone"
                  },
                  "woodenloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"finesilk"
                  },
                  "jewelerybox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"finejewels"
                  },
                  "wayfarerscenter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bazaarmap"
                  },
                  "spicerack":{
                     "active":true,
                     "startTime":0,
                     "recipe":"secretspice"
                  },
                  "fountainenclosure":{
                     "active":true,
                     "startTime":0,
                     "recipe":"smallfountaincup"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"mediterraneanAnimal1":{"complete":false}};
               break;
            case SYSTEM_ARABIAN_STALLIONS:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":2},
                  "recipe":{"level":1}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"arabianAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "enrichedgrass":2,
                        "bowlofspringwater":2,
                        "freshcutgrass":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_strawbeds",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"horse_xoa_whiteslenderneck",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "mineralspring":{
                     "active":true,
                     "startTime":0,
                     "recipe":"oasiswater"
                  },
                  "pasture":{
                     "active":true,
                     "startTime":0,
                     "recipe":"enrichedgrass"
                  },
                  "oasisgrove":{
                     "active":true,
                     "startTime":0,
                     "recipe":"woodenbeams"
                  },
                  "spinningwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"goldencotton"
                  },
                  "desertflowers":{
                     "active":true,
                     "startTime":0,
                     "recipe":"coloureddye"
                  },
                  "rockformation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"sparklinggems"
                  },
                  "goldengarden":{
                     "active":true,
                     "startTime":0,
                     "recipe":"tastytreats"
                  },
                  "miniaqueduct":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bowlofspringwater"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"arabianAnimal1":{"complete":false}};
               break;
            case SYSTEM_MAGICGARDEN:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":4},
                  "recipe":{"level":3}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"magicAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "coralessence":2,
                        "bottleofcharmedwater":2,
                        "floweressence":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_coralstones",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xsb_theslowandsteadytortoise",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "infinitybirdbath":{
                     "active":true,
                     "startTime":0,
                     "recipe":"charmedwater"
                  },
                  "hangingfountain":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bottleofcharmedwater"
                  },
                  "coralworks":{
                     "active":true,
                     "startTime":0,
                     "recipe":"floweressence"
                  },
                  "alchemisthat":{
                     "active":true,
                     "startTime":0,
                     "recipe":"youthpotion"
                  },
                  "arcademachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"coralearrings"
                  },
                  "goldenanvil":{
                     "active":true,
                     "startTime":0,
                     "recipe":"necklaceofthesea"
                  },
                  "potionscabinet":{
                     "active":true,
                     "startTime":0,
                     "recipe":"marineanklets"
                  },
                  "magicpurifier":{
                     "active":true,
                     "startTime":0,
                     "recipe":"bubblebracelet"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"magicAnimal1":{"complete":false}};
               break;
            case SYSTEM_BLACKJACKBARN:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"blackjackAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xsh_barnfruit":2,
                        "xsh_wristband":2,
                        "xsh_seedcapsule":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_hay",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"dog_xsh_cerebusthegreat",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xsh_leafbasket":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_autumnleaf"
                  },
                  "xsh_barnfruittree":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_barnfruit"
                  },
                  "xsh_mischiefpump":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_waterbucket"
                  },
                  "xsh_pulpwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_sponges"
                  },
                  "xsh_woodcart":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_woodenbranch"
                  },
                  "xsh_coincollector":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_currycomb"
                  },
                  "xsh_oreden":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_orestone"
                  },
                  "xsh_sewingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_wristband"
                  },
                  "xsh_spinmanure":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_sproutseed"
                  },
                  "xsh_hallowedfountain":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_fountaincoins"
                  },
                  "xsh_waterpoweredmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_cardedcotton"
                  },
                  "xsh_farriersfriend":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_nails"
                  },
                  "xsh_weaver":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_reedbasket"
                  },
                  "xsh_haymaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsh_cubehay"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"blackjackAnimal1":{"complete":false}};
               break;
            case SYSTEM_TOYSHOPPE:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"toyshoppeAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xtl_spoolofthread":2,
                        "xtl_windupkey":2,
                        "xtl_toywrench":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_toyhinge",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"horse_xtl_softplushie",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xtl_repairbay":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_lubricantspray"
                  },
                  "xtl_knittingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_spoolofthread"
                  },
                  "xtl_embossingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_embossedpaper"
                  },
                  "xtl_toolcupboard":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_plastichammer"
                  },
                  "xtl_paintingworkspace":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_walnutpaintbrush"
                  },
                  "xtl_makeuptable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_microfibercloth"
                  },
                  "xtl_woodchippingworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_furniturepolish"
                  },
                  "xtl_powerwasher":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_windupkey"
                  },
                  "xtl_sewingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_sewingneedles"
                  },
                  "xtl_embossingpress":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_tapemeasure"
                  },
                  "xtl_powerdrill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_toyknife"
                  },
                  "xtl_paintsprayer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_watercolors"
                  },
                  "xtl_permanentmakeupmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_makeupbrush"
                  },
                  "xtl_toychainsaw":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtl_woodchips"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"toyshoppeAnimal1":{"complete":false}};
               break;
            case SYSTEM_FORESTFAIR:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"forestfairAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xma_starlightorb":2,
                        "xma_snowdrop":2,
                        "xma_astrallantern":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_handspunsilk",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"hedgehog_daisy",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xma_crystalvalley":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_glassflower"
                  },
                  "xma_starlitlake":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_starlightorb"
                  },
                  "xma_rainbowfields":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_rainbowfleece"
                  },
                  "xma_hangingrock":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_goldenstrings"
                  },
                  "xma_bluemountain":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_foolsgold"
                  },
                  "xma_treeoflife":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_foragingherbs"
                  },
                  "xma_runehenge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_runestones"
                  },
                  "xma_glassblowerskiln":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_snowdrop"
                  },
                  "xma_lampmakerstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_astrallantern"
                  },
                  "xma_drapersweave":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_rainbowsilk"
                  },
                  "xma_minstrelsgallery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_celticlute"
                  },
                  "xma_alchemistsmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_goldcoins"
                  },
                  "xma_apothecary":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_healingsalve"
                  },
                  "xma_druidsdolmen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xma_arcanespell"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"forestfairAnimal1":{"complete":false}};
               break;
            case SYSTEM_ROYALSTABLE:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"royalstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xmb_goldenbucket":2,
                        "xmb_giantorb":2,
                        "xmb_elixiroflight":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_rooftiles",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"badger_xmb_royal",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xmb_magicdustbarrel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_magicdust"
                  },
                  "xmb_marvellousfountain":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_goldenbucket"
                  },
                  "xmb_dragongargoyle":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_mysticfire"
                  },
                  "xmb_weldingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_weldinghammer"
                  },
                  "xmb_spinningwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_magicalyarn"
                  },
                  "xmb_myticalengravingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_engravingtools"
                  },
                  "xmb_mistifiedflowers":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_naturalpaints"
                  },
                  "xmb_sorcerersobservatortree":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_giantorb"
                  },
                  "xmb_flowoflife":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_elixiroflight"
                  },
                  "xmb_regalkiln":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_goldbricks"
                  },
                  "xmb_weldingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_crownofdreams"
                  },
                  "xmb_sewingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_tapestryoflife"
                  },
                  "xmb_engravingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_ringofrunes"
                  },
                  "xmb_paintingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmb_stainedglasstile"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"royalstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_RODEORANCH:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"rodeoranchAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xwa_syntheticleather":2,
                        "xwa_simplehorseshoe":2,
                        "xwa_cowboyhat":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_pailwater",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"mouse_xwa_outlaw",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xwa_ironmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_ironore"
                  },
                  "xwa_fauxleatherfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_syntheticleather"
                  },
                  "xwa_livestockbarn":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_naturalbristle"
                  },
                  "xwa_lassoworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_stiffnylonthread"
                  },
                  "xwa_denimfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_sturdycottontwill"
                  },
                  "xwa_musicshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_steelstring"
                  },
                  "xwa_ranchbrewery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_maltedbarley"
                  },
                  "xwa_smithysworkstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_simplehorseshoe"
                  },
                  "xwa_fauxleathermaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_cowboyhat"
                  },
                  "xwa_ranchstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_hoofpick"
                  },
                  "xwa_ropemakerstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_ropedcandle"
                  },
                  "xwa_denimweaver":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_denimclothroll"
                  },
                  "xwa_musicianstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_countryguitar"
                  },
                  "xwa_bubblymaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwa_hopjuice"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"rodeoranchAnimal1":{"complete":false}};
               break;
            case SYSTEM_TIDEHOMESTEAD:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"tidehomesteadAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xsa_heavyanchors":2,
                        "xsa_gunpowder":2,
                        "xsa_piratehat":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_fishingnets",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chicken_xsa_shell",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xsa_ropestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_sturdyrope"
                  },
                  "xsa_anchorsmith":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_heavyanchors"
                  },
                  "xsa_plankworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_sturdyplanks"
                  },
                  "xsa_goldrefinery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_goldbars"
                  },
                  "xsa_barrelshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_barrels"
                  },
                  "xsa_shellstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_pearlshell"
                  },
                  "xsa_coralworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_corals"
                  },
                  "xsa_blackbeardsworkstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_gunpowder"
                  },
                  "xsa_piratestopstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_piratehat"
                  },
                  "xsa_shellpearlsstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_seashells"
                  },
                  "xsa_explorerstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_explorertelescope"
                  },
                  "xsa_shipassembler":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_cannonball"
                  },
                  "xsa_shipaccessoriestable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_drinkingmug"
                  },
                  "xsa_medievaldispenser":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsa_mealplate"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"tidehomesteadAnimal1":{"complete":false}};
               break;
            case SYSTEM_SAVANNAHRESERVE:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"savannahreserveAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xaf_bagofclay":2,
                        "xaf_dogwhistle":2,
                        "xaf_clayearrings":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_woodslice",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"bird_xaf_guineaturaco",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xaf_explorermysterybox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_safetyandskillmanual"
                  },
                  "xaf_claymakerbox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_bagofclay"
                  },
                  "xaf_forestbarn":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_woodandhay"
                  },
                  "xaf_crystalbeadbowl":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_beadbundle"
                  },
                  "xaf_discbox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_musicalnotes"
                  },
                  "xaf_flowerpestlemortar":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_flowerpaint"
                  },
                  "xaf_canepeeler":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_canestrands"
                  },
                  "xaf_survivortent":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_dogwhistle"
                  },
                  "xaf_potterswheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_clayearrings"
                  },
                  "xaf_groomingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_cattlecomb"
                  },
                  "xaf_craftstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_craftybowls"
                  },
                  "xaf_musiccase":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_ududrum"
                  },
                  "xaf_paintingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_handcraftedspoons"
                  },
                  "xaf_weavingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xaf_wovenhat"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"savannahreserveAnimal1":{"complete":false}};
               break;
            case SYSTEM_XTR_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"grimreapersbyreAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xtr_burningflame":2,
                        "xtr_bagoftreat":2,
                        "xtr_eeriecandles":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xtr_crystalnail",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chicken_xtr_skullcrownchick",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xtr_sugarcanecrusher":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_cubedsugar"
                  },
                  "xtr_cursedtorch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_burningflame"
                  },
                  "xtr_magicboard":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_notingpad"
                  },
                  "xtr_jokerinthebox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_spookypranksbox"
                  },
                  "xtr_magicstump":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_witchwand"
                  },
                  "xtr_monstercushions":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_monsterpetbed"
                  },
                  "xtr_hauntedtralley":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_monstercloche"
                  },
                  "xtr_creepycandybooth":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_bagoftreat"
                  },
                  "xtr_spookycandlecase":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_eeriecandles"
                  },
                  "xtr_enchantedcloset":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_hornedheaddress"
                  },
                  "xtr_rockingskullchair":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_prankwisps"
                  },
                  "xtr_spellcenter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_antispellpowder"
                  },
                  "xtr_hauntedcradle":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_creepyblankie"
                  },
                  "xtr_stewypot":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xtr_demonbait"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"grimreapersbyreAnimal1":{"complete":false}};
               break;
            case SYSTEM_XIN_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"royalkalakshetraAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xin_dyepowder":2,
                        "xin_claypot":2,
                        "xin_traditionaldupatta":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xin_stonebricks",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chicken_xin_traditional",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xin_claypit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_rawclay"
                  },
                  "xin_dyevat":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_dyepowder"
                  },
                  "xin_cottonmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_cottonyarn"
                  },
                  "xin_gemstonemine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_peacockore"
                  },
                  "xin_luteristsstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_woodpolish"
                  },
                  "xin_vedicashram":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_aromaticpotion"
                  },
                  "xin_woodworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_woodenplanks"
                  },
                  "xin_potterywheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_claypot"
                  },
                  "xin_dyetanneries":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_traditionaldupatta"
                  },
                  "xin_textilemachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_saddlecloth"
                  },
                  "xin_jewelrysmith":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_goldandrubynecklace"
                  },
                  "xin_instrumentworkspace":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_traditionaltabla"
                  },
                  "xin_vanitymirror":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_kohlkajal"
                  },
                  "xin_carpentrybench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xin_woodensculpture"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"royalkalakshetraAnimal1":{"complete":false}};
               break;
            case SYSTEM_XJP_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"izanamihavenAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xjp_dryclay":2,
                        "xjp_farmersraincoat":2,
                        "xjp_claycups":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xjp_glasssheet",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xjp_raincoatredpanda",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xjp_haymaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_ricestraw"
                  },
                  "xjp_claypulley":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_dryclay"
                  },
                  "xjp_inkmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_inkpowder"
                  },
                  "xjp_cottonwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_cottonyarn"
                  },
                  "xjp_ironmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_ironore"
                  },
                  "xjp_steelmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_steelingot"
                  },
                  "xjp_ricecooker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_ricebowl"
                  },
                  "xjp_strawsewing":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_farmersraincoat"
                  },
                  "xjp_claypottey":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_claycups"
                  },
                  "xjp_bookshelf":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_inkpot"
                  },
                  "xjp_clothesstore":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_haori"
                  },
                  "xjp_armoury":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_sujikabuto"
                  },
                  "xjp_weaponforge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_tanto"
                  },
                  "xjp_foodstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_sushiplate"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"izanamihavenAnimal1":{"complete":false}};
               break;
            case SYSTEM_XJP_ELITEHORSES_MS:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"izanagishelterAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xjp_claybricks":2,
                        "xjp_strawraincoat":2,
                        "xjp_teacups":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xjp_texturedglasssheet",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"rabbit_xjp_ronin",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xjp_crankedbaler":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_haystraw"
                  },
                  "xjp_claypit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_claybricks"
                  },
                  "xjp_dyeingvat":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_inkpaste"
                  },
                  "xjp_spinningwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_cottonstrings"
                  },
                  "xjp_bronzemine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_copperore"
                  },
                  "xjp_leadmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_leadore"
                  },
                  "xjp_steamcooker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_bowlandchopsticks"
                  },
                  "xjp_strawweaver":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_strawraincoat"
                  },
                  "xjp_kickwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_teacups"
                  },
                  "xjp_bookcase":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_inkbottle"
                  },
                  "xjp_worktable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_traditionaltunic"
                  },
                  "xjp_garrison":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_kabutomask"
                  },
                  "xjp_blacksmithforge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_shortblade"
                  },
                  "xjp_snackkiosk":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjp_foodplatter"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"izanagishelterAnimal1":{"complete":false}};
               break;
            case SYSTEM_XMO_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"olympusstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xmo_magiccoal":2,
                        "xmo_seamanstrident":2,
                        "xmo_devilspitchfork":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xmo_triglyph",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"rooster_xmo_alectryon",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xmo_cupidsabode":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_seawaves"
                  },
                  "xmo_anvil":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_magiccoal"
                  },
                  "xmo_oystertank":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_pearlheart"
                  },
                  "xmo_underworldmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_ironshavings"
                  },
                  "xmo_potionbrewer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_mysticcrystals"
                  },
                  "xmo_musicalchest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_sheetmusic"
                  },
                  "xmo_galacticsky":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_galacticstars"
                  },
                  "xmo_posiedonschest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_seamanstrident"
                  },
                  "xmo_hadessdungeon":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_devilspitchfork"
                  },
                  "xmo_erosbriery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_lovespell"
                  },
                  "xmo_aresarmoury":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_corinthianhelmet"
                  },
                  "xmo_godshenge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_ageingpotion"
                  },
                  "xmo_apollosmusicals":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_lyracrete"
                  },
                  "xmo_zeusclouds":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmo_thundercrown"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"olympusstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XBO_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"carnavaltheatreAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xbo_deadlyenvy":2,
                        "xbo_ringmasterpedestal":2,
                        "xbo_cannonballhelmet":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xbo_tentrods",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chicken_xbo_twofaced",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xbo_coffinofgreed":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_deadlygreed"
                  },
                  "xbo_coffinofenvy":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_deadlyenvy"
                  },
                  "xbo_coffinofgluttony":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_deadlygluttony"
                  },
                  "xbo_coffinofwrath":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_deadlywrath"
                  },
                  "xbo_coffinoflust":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_deadlylust"
                  },
                  "xbo_coffinofsloth":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_deadlysloth"
                  },
                  "xbo_coffinofpride":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_deadlypride"
                  },
                  "xbo_carnivalwagon":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_ringmasterpedestal"
                  },
                  "xbo_circuscannon":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_cannonballhelmet"
                  },
                  "xbo_clownroom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_clownshoes"
                  },
                  "xbo_circuspantry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_bloodycorn"
                  },
                  "xbo_darktheatre":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_hoolahoops"
                  },
                  "xbo_musicbox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_drumsofhell"
                  },
                  "xbo_gypsyreader":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbo_circustarotcards"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"carnavaltheatreAnimal1":{"complete":false}};
               break;
            case SYSTEM_XUW_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"underwaterarenaAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xuw_coralpiece":2,
                        "xuw_scaletop":2,
                        "xuw_coraltreecarving":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xuw_diamondchisel",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"hedgehog_xuw_glowing",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xuw_harvestedscalebasket":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_shinyfishscales"
                  },
                  "xuw_coralpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_coralpiece"
                  },
                  "xuw_rockcropping":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_rockslab"
                  },
                  "xuw_crystalvein":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_crystalshards"
                  },
                  "xuw_bubblepit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_collectedbubbles"
                  },
                  "xuw_seaweedgrove":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_rollofseaweed"
                  },
                  "xuw_gemstonemine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_uncutgemstones"
                  },
                  "xuw_scaleworkbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_scaletop"
                  },
                  "xuw_coralsculptingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_coraltreecarving"
                  },
                  "xuw_stonemasonry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_stonespearhead"
                  },
                  "xuw_crystalcarver":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_fluoritesphere"
                  },
                  "xuw_bubbleformer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_rainbowformedbubble"
                  },
                  "xuw_seasnacksoven":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_seaweedwraps"
                  },
                  "xuw_gemjewelryworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xuw_seahorseearrings"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"underwaterarenaAnimal1":{"complete":false}};
               break;
            case SYSTEM_XHH_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"peacefulstablesAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xhh_curvedwood":2,
                        "xhh_daisychain":2,
                        "xhh_panpipes":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xhh_wiremesh",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"turtle_xhh_ringedmap",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xhh_logflowerpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_freshcutflowers"
                  },
                  "xhh_townlumbermill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_curvedwood"
                  },
                  "xhh_fruitorchard":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_mixedfruitbasket"
                  },
                  "xhh_smallmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_metalpieces"
                  },
                  "xhh_spoolspinner":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_cottonbolt"
                  },
                  "xhh_butterchurner":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_homemadebutter"
                  },
                  "xhh_naturaldyecooker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_colordye"
                  },
                  "xhh_handicraftstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_daisychain"
                  },
                  "xhh_instrumentworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_panpipes"
                  },
                  "xhh_juicer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_applejuice"
                  },
                  "xhh_metaljewelryworshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_peacependant"
                  },
                  "xhh_cottonspinningwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_chocolatechippers"
                  },
                  "xhh_vintageoven":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_headband"
                  },
                  "xhh_coloringworkbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhh_landscapepainting"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"peacefulstablesAnimal1":{"complete":false}};
               break;
            case SYSTEM_XTI_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"rutanasstablesAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xti_whiteclay":2,
                        "xti_strawhat":2,
                        "xti_claycoffeecup":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xti_goldenspire",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"turtle_xti_manda",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xti_haystack":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_strawpile"
                  },
                  "xti_claypit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_whiteclay"
                  },
                  "xti_goldmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_goldore"
                  },
                  "xti_mulberryplant":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_silkcocoon"
                  },
                  "xti_ricecooker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_stickyrice"
                  },
                  "xti_flowerbush":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_flowerbunch"
                  },
                  "xti_lumbermill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_woodenplank"
                  },
                  "xti_strawsewing":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_strawhat"
                  },
                  "xti_claywheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_claycoffeecup"
                  },
                  "xti_goldrefinery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_traditionalearrings"
                  },
                  "xti_thailoom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_tradtionaldress"
                  },
                  "xti_foodstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_rainbowrolls"
                  },
                  "xti_flowershop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_flowerfloats"
                  },
                  "xti_instrumentbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xti_thonandrammana"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"rutanasstablesAnimal1":{"complete":false}};
               break;
            case SYSTEM_XDW_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"imaginariumofbeastsAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xdw_fruitbowl":2,
                        "xdw_twirlhat":2,
                        "xdw_leafbread":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xdw_barkshroom",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"turtle_xdw_flower",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xdw_pixiebarn":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_magicalcotton"
                  },
                  "xdw_berryshrub":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_fruitbowl"
                  },
                  "xdw_pitcherplant":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_fairydust"
                  },
                  "xdw_crystaltoadstool":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_rainbowcrystal"
                  },
                  "xdw_glassblower":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_emptyvial"
                  },
                  "xdw_floralplant":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_flowerbasket"
                  },
                  "xdw_fairyglen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_enchantedlog"
                  },
                  "xdw_knittingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_twirlhat"
                  },
                  "xdw_pastrybench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_leafbread"
                  },
                  "xdw_fairyshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_butterflywings"
                  },
                  "xdw_crystalcave":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_flowerring"
                  },
                  "xdw_pixiecauldron":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_tippingpotion"
                  },
                  "xdw_floralboutique":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_daisyballlantern"
                  },
                  "xdw_pixietreehouse":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdw_featherpanpipes"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"imaginariumofbeastsAnimal1":{"complete":false}};
               break;
            case SYSTEM_XFE_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"llyncastersstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xfe_lumber":2,
                        "xfe_decorativehorseshoe":2,
                        "xfe_woolrug":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xfe_stonetrowel",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xfe_europeanhare",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xfe_treesandshrubs":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_freshproduce"
                  },
                  "xfe_woodchopper":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_lumber"
                  },
                  "xfe_animalgroomingkit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_groomingbrush"
                  },
                  "xfe_spoolandneedle":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_thread"
                  },
                  "xfe_metate":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_handmirror"
                  },
                  "xfe_wigstand":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_wig"
                  },
                  "xfe_flowers":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_pruningshear"
                  },
                  "xfe_brickoven":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_decorativehorseshoe"
                  },
                  "xfe_woodcarvingtools":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_woolrug"
                  },
                  "xfe_animalstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_antiquemirror"
                  },
                  "xfe_weavingframe":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_englishtrifle"
                  },
                  "xfe_makeuppaint":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_rosered"
                  },
                  "xfe_dressingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_daisyhaircomb"
                  },
                  "xfe_jewellerystall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfe_pompadourupdo"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"llyncastersstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XBR_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"carnivalstageAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xbr_handmadepaper":2,
                        "xbr_decorativehorseshoe":2,
                        "xbr_carnivaleflyers":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xbr_toolbox",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"rabbit_xbr_carimboflowerhare",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xbr_lumberstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_woodendowels"
                  },
                  "xbr_paperstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_handmadepaper"
                  },
                  "xbr_rubbermill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_rubbersheets"
                  },
                  "xbr_flaxmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_flaxfiber"
                  },
                  "xbr_cottonmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_cottonyarn"
                  },
                  "xbr_dyestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_pigments"
                  },
                  "xbr_flowergarden":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_petals"
                  },
                  "xbr_luterist":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_decorativehorseshoe"
                  },
                  "xbr_printingpress":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_carnivaleflyers"
                  },
                  "xbr_balloonstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_heartballoons"
                  },
                  "xbr_costumestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_rioflamingocostume"
                  },
                  "xbr_dressingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_lipsticks"
                  },
                  "xbr_maskcounter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_bluebeakmask"
                  },
                  "xbr_featherypropsstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbr_featheredheaddress"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"carnivalstageAnimal1":{"complete":false}};
               break;
            case SYSTEM_XCH_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"frostygrangeAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xch_woodplanks":2,
                        "xch_snowglobe":2,
                        "xch_woodentoy":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xch_screws",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"penguin_xch_gingerbread",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xch_snowmound":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_snowballs"
                  },
                  "xch_carpentersbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_woodplanks"
                  },
                  "xch_woolshearer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_woolstrings"
                  },
                  "xch_paperscreening":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_paperstack"
                  },
                  "xch_flourgrinder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_flourbag"
                  },
                  "xch_berrybush":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_freshberries"
                  },
                  "xch_gemboulder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_magicalgems"
                  },
                  "xch_snowmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_snowglobe"
                  },
                  "xch_carpentersworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_woodentoy"
                  },
                  "xch_woolmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_christmasgloves"
                  },
                  "xch_paperfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_giftwrappers"
                  },
                  "xch_openoven":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_holidaybrownie"
                  },
                  "xch_juicecart":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_elderflowerlemonade"
                  },
                  "xch_gemstore":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xch_queenearrings"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"frostygrangeAnimal1":{"complete":false}};
               break;
            case SYSTEM_XHA_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"allhalloweenstoreAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xha_bones":2,
                        "xha_batwingheadband":2,
                        "xha_toytrident":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xha_gravediggers",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"turtle_xha_mutantmechtotoise",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xha_graves":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_gravestone"
                  },
                  "xha_crypt":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_bones"
                  },
                  "xha_mummysarcophagus":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_mummywraps"
                  },
                  "xha_ghostlyportal":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_ectoplasm"
                  },
                  "xha_dungeon":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_ballandchain"
                  },
                  "xha_madscientistslab":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_radioactivebug"
                  },
                  "xha_monsternest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_monstereggs"
                  },
                  "xha_halloweenheadgear":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_batwingheadband"
                  },
                  "xha_halloweenaccessoriescloset":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_toytrident"
                  },
                  "xha_capestand":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_vampirecape"
                  },
                  "xha_candlemaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_pumpkincandle"
                  },
                  "xha_halloweenbakery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_witchhatcupcakes"
                  },
                  "xha_maskgallery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_vanderpoolmask"
                  },
                  "xha_halloweenshoerack":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xha_witchsshoes"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"allhalloweenstoreAnimal1":{"complete":false}};
               break;
            case SYSTEM_XFW_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"alpinerentalsAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xfw_coloredyarn":2,
                        "xfw_childrenssledge":2,
                        "xfw_holidaycards":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xfw_snowshovel",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"dog_xfw_wisewinter",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xfw_lumberpile":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_woodchips"
                  },
                  "xfw_wooldyieng":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_coloredyarn"
                  },
                  "xfw_paperautovat":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_coloredpaper"
                  },
                  "xfw_oremine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_metalingots"
                  },
                  "xfw_radiator":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_steamcloud"
                  },
                  "xfw_kerosenepump":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_kerosenecan"
                  },
                  "xfw_snowmound":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_snowcubes"
                  },
                  "xfw_steambender":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_childrenssledge"
                  },
                  "xfw_printingpress":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_holidaycards"
                  },
                  "xfw_glassmakerskiln":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_dessertglasses"
                  },
                  "xfw_woodfiredoven":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_prinsesstarta"
                  },
                  "xfw_knittingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_holidaybeanie"
                  },
                  "xfw_oldlathe":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_holidayskis"
                  },
                  "xfw_macramestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfw_danglertrees"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"alpinerentalsAnimal1":{"complete":false}};
               break;
            case SYSTEM_XJM_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"ani-mallAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xjm_pigmentmound":2,
                        "xjm_jutecord":2,
                        "xjm_metalingot":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xjm_quartz",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chicken_xjm_firestripe",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xjm_juteplantation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_jutefiber"
                  },
                  "xjm_pigmentgrinder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_pigmentmound"
                  },
                  "xjm_gemstonequarry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_roughstones"
                  },
                  "xjm_metalmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_metalore"
                  },
                  "xjm_timberwoods":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_timber"
                  },
                  "xjm_stonequarry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_constructionstone"
                  },
                  "xjm_shellfishculture":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_seashells"
                  },
                  "xjm_juteloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_jutecord"
                  },
                  "xjm_metalkiln":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_metalingot"
                  },
                  "xjm_gemstoneworkstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_rubynecklace"
                  },
                  "xjm_pigmentmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_rocred"
                  },
                  "xjm_woodworkbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_watertrough"
                  },
                  "xjm_stoneworkstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_primitivealarm"
                  },
                  "xjm_seashellbay":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xjm_conchshell"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"ani-mallAnimal1":{"complete":false}};
               break;
            case SYSTEM_XWI_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"eckhartsstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xwi_brownbaskets":2,
                        "xwi_orangejuice":2,
                        "xwi_applecrate":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xwi_softwoodfence",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"bird_xwi_sparklingmyna",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xwi_grainmasher":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_plateofgrains"
                  },
                  "xwi_basketweaver":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_brownbaskets"
                  },
                  "xwi_spinningloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_woolenbundle"
                  },
                  "xwi_flowerpreserverbox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_frozenrose"
                  },
                  "xwi_surprisegiftmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_giftbox"
                  },
                  "xwi_icecrushingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_crushedice"
                  },
                  "xwi_magicmountaincart":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_aurorarocks"
                  },
                  "xwi_foodprocessingstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_orangejuice"
                  },
                  "xwi_sundaymarket":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_applecrate"
                  },
                  "xwi_designstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_wintersweater"
                  },
                  "xwi_floriststent":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_flowerpot"
                  },
                  "xwi_giftshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_dottedribbons"
                  },
                  "xwi_candycart":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_magiclollys"
                  },
                  "xwi_rocksculptingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwi_snowglobe"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"eckhartsstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XTY_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"italianstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xty_hardwooddowels":2,
                        "xty_marbleangel":2,
                        "xty_italiandesignerchair":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xty_pneumaticdrill",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xty_nightbardmeerkat",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xty_quarry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_onyxslabs"
                  },
                  "xty_lumberstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_hardwooddowels"
                  },
                  "xty_pigmentstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_artistspaints"
                  },
                  "xty_smallmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_sheetmetal"
                  },
                  "xty_sugarmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_sugardust"
                  },
                  "xty_oldtuscanloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_italianfabrics"
                  },
                  "xty_sandmeltingfurnace":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_colouredglass"
                  },
                  "xty_sculptorsstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_marbleangel"
                  },
                  "xty_carpentersbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_italiandesignerchair"
                  },
                  "xty_paintersstudio":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_frescotree"
                  },
                  "xty_kitchencounter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_fancycakestand"
                  },
                  "xty_toolingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_paintbrushes"
                  },
                  "xty_sarto":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_tuscansunkimono"
                  },
                  "xty_glassmakerskiln":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xty_italiancordiaglass"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"italianstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XDV_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"alchemistslabAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xdv_magicherbs":2,
                        "xdv_nightwizardshat":2,
                        "xdv_healingherbpaste":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xdv_parchmentsheets",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"tapir_xdv_flower",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xdv_elixrcauldron":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_elixrofcreation"
                  },
                  "xdv_magicherbgarden":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_magicherbs"
                  },
                  "xdv_enchantedkiln":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_enchantedingot"
                  },
                  "xdv_gemstonequarry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_gemstones"
                  },
                  "xdv_interdimensionalportal":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_energon"
                  },
                  "xdv_magicpond":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_magicalnectar"
                  },
                  "xdv_scribestable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_scrollofwisdom"
                  },
                  "xdv_hatmakerstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_nightwizardshat"
                  },
                  "xdv_wizardsapothecary":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_healingherbpaste"
                  },
                  "xdv_quartermastersstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_foragersprotectivecape"
                  },
                  "xdv_magicamuletstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_lordsseal"
                  },
                  "xdv_wizardstaffstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_rainbringerstaff"
                  },
                  "xdv_magicpotionstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_rejuvenationpotion"
                  },
                  "xdv_ancientbookshelf":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdv_naturalsciencetome"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"alchemistslabAnimal1":{"complete":false}};
               break;
            case SYSTEM_XCB_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"caribbeanstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xcb_rainbowcoral":2,
                        "xcb_beachcomberstrawhat":2,
                        "xcb_conchpearlnecklace":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xcb_coiledsteel",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"turtle_xcb_molas",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xcb_strawbales":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_stitchedstraw"
                  },
                  "xcb_coralreef":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_rainbowcoral"
                  },
                  "xcb_woodenlogpile":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_patternblock"
                  },
                  "xcb_souvenirstand":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_carnivalmask"
                  },
                  "xcb_potterswheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_clayblock"
                  },
                  "xcb_mocktailmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_caribbeanmocktail"
                  },
                  "xcb_caribbeanboombox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_mixtape"
                  },
                  "xcb_hatkiosk":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_beachcomberstrawhat"
                  },
                  "xcb_caribbeanjewelrystore":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_conchpearlnecklace"
                  },
                  "xcb_traditionalclothshack":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_batikquilt"
                  },
                  "xcb_souvenirshack":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_beachhammock"
                  },
                  "xcb_ceramicsstore":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_belizeanbaskets"
                  },
                  "xcb_barcounter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_caribbeanhotsauce"
                  },
                  "xcb_musicdisplay":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcb_gourdmarimba"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"caribbeanstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XRU_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"izbastableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xru_russianrug":2,
                        "xru_fireworksfuse":2,
                        "xru_russianmatryoshka":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xru_grasscreteslab",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xru_barguzinsable",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xru_bastshoetable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_bastshoes"
                  },
                  "xru_rugstand":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_russianrug"
                  },
                  "xru_russianhattable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_trapperhat"
                  },
                  "xru_ticketbooth":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_carnivalticket"
                  },
                  "xru_samovar":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_samovarteapot"
                  },
                  "xru_russianhoneystand":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_russianhoney"
                  },
                  "xru_russianjewelrybox":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_finiftynecklace"
                  },
                  "xru_fireworksmortar":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_fireworksfuse"
                  },
                  "xru_toybooth":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_russianmatryoshka"
                  },
                  "xru_circustrunk":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_floatingballoons"
                  },
                  "xru_foodvan":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_khvorost"
                  },
                  "xru_maskstand":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_kokoshnikmask"
                  },
                  "xru_musictheatre":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_bayan"
                  },
                  "xru_handicraftstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xru_lacquerbox"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"izbastableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XNF_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"blacksmithsfoundryAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xnf_metalshavings":2,
                        "xnf_fruitwoodjar":2,
                        "xnf_horseshoes":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xnf_woodenbeam",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chicken_xnf_regimentsoldier",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xnf_medicinechest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_smellingsalt"
                  },
                  "xnf_ironoreboulder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_metalshavings"
                  },
                  "xnf_cutwoodstorage":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_sawdust"
                  },
                  "xnf_leathersheets":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_leathercoil"
                  },
                  "xnf_cottonbasket":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_knittingyarn"
                  },
                  "xnf_toolchest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_corkscrew"
                  },
                  "xnf_silicaslab":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_silicasand"
                  },
                  "xnf_apothecarytable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_fruitwoodjar"
                  },
                  "xnf_metalworkstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_horseshoes"
                  },
                  "xnf_woodworktable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_2x4plank"
                  },
                  "xnf_leathercraftingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_saddle"
                  },
                  "xnf_spinningwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_cottonshirt"
                  },
                  "xnf_craftingtoolstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_clawhammer"
                  },
                  "xnf_glassfurnace":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xnf_glassaletankard"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"blacksmithsfoundryAnimal1":{"complete":false}};
               break;
            case SYSTEM_XIS_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"seasidespaAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xis_assortedberries":2,
                        "xis_footabacus":2,
                        "xis_oatmealshake":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xis_olivewoodplank",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"cat_xis_sunnyparadise",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xis_teagarden":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_tealeaves"
                  },
                  "xis_berryplantation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_assortedberries"
                  },
                  "xis_saltpan":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_saltmound"
                  },
                  "xis_oildistillery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_essentialoils"
                  },
                  "xis_fruitpeeler":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_fruitrinds"
                  },
                  "xis_centrifuge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_naturalextracts"
                  },
                  "xis_incensestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_scentedincense"
                  },
                  "xis_massageparlour":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_footabacus"
                  },
                  "xis_healthyshakespress":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_oatmealshake"
                  },
                  "xis_teabrewery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_nettletea"
                  },
                  "xis_therapeuticbath":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_deadseasalt"
                  },
                  "xis_unguentslab":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_honeyparafum"
                  },
                  "xis_handmadesoaplab":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_teatreesoap"
                  },
                  "xis_healthfoodscafe":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xis_muesliberryyoghurt"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"seasidespaAnimal1":{"complete":false}};
               break;
            case SYSTEM_XHX_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"mutanttron3000Animal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xhx_lightningjar":2,
                        "xhx_madsciencegloves":2,
                        "xhx_electricswitch":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xhx_glassbeakers",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"monkey_xhx_madscience",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xhx_graves":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_reanimationspecimens"
                  },
                  "xhx_lightningcollector":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_lightningjar"
                  },
                  "xhx_swamp":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_slugs"
                  },
                  "xhx_mines":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_specialmetals"
                  },
                  "xhx_dungeon":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_ballandchain"
                  },
                  "xhx_drawingboard":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_topsecretformulas"
                  },
                  "xhx_dumpsite":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_toxicwaste"
                  },
                  "xhx_madsciencewardrobe":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_madsciencegloves"
                  },
                  "xhx_labstationery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_electricswitch"
                  },
                  "xhx_monsterizer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_monsterjaws"
                  },
                  "xhx_chemicallab":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_mutantgrowthformula"
                  },
                  "xhx_monsterkitchen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_toxicdrink"
                  },
                  "xhx_monsterwardrobe":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_frankenstientux"
                  },
                  "xhx_madsciencechest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhx_bonesaw"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"mutanttron3000Animal1":{"complete":false}};
               break;
            case SYSTEM_XWX_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"yuletidestableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xwx_yarn":2,
                        "xwx_nobleschair":2,
                        "xwx_wintercloak":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xwx_goldbaubles",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chicken_xwx_winterknit",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xwx_hardwoodforest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_dowels"
                  },
                  "xwx_sheeppen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_yarn"
                  },
                  "xwx_metalbuffer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_tools"
                  },
                  "xwx_kingsmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_ironingots"
                  },
                  "xwx_buildersforge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_plans"
                  },
                  "xwx_dyemaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_paionts"
                  },
                  "xwx_astronomerstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_starcharts"
                  },
                  "xwx_lumberyard":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_nobleschair"
                  },
                  "xwx_loom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_wintercloak"
                  },
                  "xwx_beauticianshome":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_combs"
                  },
                  "xwx_shipbuilder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_mast"
                  },
                  "xwx_alchemistsstore":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_vialofenergy"
                  },
                  "xwx_armourer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_shield"
                  },
                  "xwx_artist":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xwx_paintedsails"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"yuletidestableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XCA_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"menaragardensAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xca_woolenyarn":2,
                        "xca_khamsapendant":2,
                        "xca_fibula":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xca_strawmats",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"duck_xca_moorish",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xca_metalforge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_metalbars"
                  },
                  "xca_woolspinner":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_woolenyarn"
                  },
                  "xca_mudpit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_claybars"
                  },
                  "xca_forest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_woodenpile"
                  },
                  "xca_brickkiln":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_brick"
                  },
                  "xca_flowerpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_gazniaflower"
                  },
                  "xca_silo":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_foodbasket"
                  },
                  "xca_jewellersworkbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_khamsapendant"
                  },
                  "xca_carpetmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_fibula"
                  },
                  "xca_potterystation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_boucherouiterug"
                  },
                  "xca_furnituremaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_souptureen"
                  },
                  "xca_windmillservicestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_moorishbench"
                  },
                  "xca_artstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_gears"
                  },
                  "xca_kitchen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xca_briouats"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"menaragardensAnimal1":{"complete":false}};
               break;
            case SYSTEM_XBL_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"princelystablesAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xbl_rawgoldstone":2,
                        "xbl_toycarriage":2,
                        "xbl_kundannechlace":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xbl_tuskertopiary",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xbl_ceylonsnake",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xbl_woodchopper":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_lumber"
                  },
                  "xbl_goldmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_rawgoldstone"
                  },
                  "xbl_glassmold":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_glasspieces"
                  },
                  "xbl_antiquespinningwheel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_threadspools"
                  },
                  "xbl_herbshrub":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_himalayanherb"
                  },
                  "xbl_chakki":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_grains"
                  },
                  "xbl_weldingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_metalnugget"
                  },
                  "xbl_carpenter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_toycarriage"
                  },
                  "xbl_goldsmith":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_kundannechlace"
                  },
                  "xbl_vintageglassblower":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_antiquechandelier"
                  },
                  "xbl_loom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_royalrug"
                  },
                  "xbl_ayurvedicapothecary":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_rennet"
                  },
                  "xbl_cookingpot":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_roti"
                  },
                  "xbl_blacksmith":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbl_muscledcuirass"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"princelystablesAnimal1":{"complete":false}};
               break;
            case SYSTEM_XRT_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"ostlersstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xrt_metalblock":2,
                        "xrt_surcingle":2,
                        "xrt_fancyhalter":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xrt_cornerpost",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"duck_xrt_sailor",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xrt_tannerbarrel":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_leatherroll"
                  },
                  "xrt_vintagemetalforge":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_metalblock"
                  },
                  "xrt_oldminecart":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_copperwire"
                  },
                  "xrt_bigwindturbine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_electricity"
                  },
                  "xrt_skilltoken":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_toolmaker"
                  },
                  "xrt_pinefarm":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_pinelogs"
                  },
                  "xrt_farmpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_ingredientbasket"
                  },
                  "xrt_leatherstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_surcingle"
                  },
                  "xrt_horseaccessorystation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_fancyhalter"
                  },
                  "xrt_electronicsworkbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_metalhorseshoe"
                  },
                  "xrt_powerstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_americangramophone"
                  },
                  "xrt_boatbuildermachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_batteries"
                  },
                  "xrt_furniturestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_wavesteering"
                  },
                  "xrt_dinerkitchen":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xrt_delicioushotdog"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"ostlersstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XSU_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"nanookstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xsu_roundleather":2,
                        "xsu_woodenharpoon":2,
                        "xsu_muklukboots":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xsu_rootyhammer",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"weasel_xsu_alaskan",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xsu_woodworkbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_alaskanlumber"
                  },
                  "xsu_leatherworkingtable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_roundleather"
                  },
                  "xsu_ironmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_hematiteore"
                  },
                  "xsu_stonequarry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_avonitestone"
                  },
                  "xsu_cottonbale":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_coloredcottonballs"
                  },
                  "xsu_paintmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_paintbottles"
                  },
                  "xsu_sugarmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_ethanol"
                  },
                  "xsu_woodencraftworks":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_woodenharpoon"
                  },
                  "xsu_winterclothesrack":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_muklukboots"
                  },
                  "xsu_ironmongerstore":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_inuitfishhook"
                  },
                  "xsu_lapidarymachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_stonearrowheads"
                  },
                  "xsu_campingtent":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_firstaidkit"
                  },
                  "xsu_artstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_divinationstone"
                  },
                  "xsu_chemistsbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xsu_spiritswab"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"nanookstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XCL_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"candyfactoryAnimals1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xcl_cocoapowder":2,
                        "xcl_lollipopearrings":2,
                        "xcl_cottoncandyhair":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xcl_brightcandylights",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chipmunk_xcl_cookiecutter",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xcl_freshmilkdairy":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_condensedmilk"
                  },
                  "xcl_roastingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_cocoapowder"
                  },
                  "xcl_stoneflourmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_floursack"
                  },
                  "xcl_honeynest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_sugarblocks"
                  },
                  "xcl_sugarplant":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_honeyvessel"
                  },
                  "xcl_syrupmakersaucepan":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_caramelmix"
                  },
                  "xcl_icefactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_icechunks"
                  },
                  "xcl_candyjeweler":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_lollipopearrings"
                  },
                  "xcl_cottoncandymachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_cottoncandyhair"
                  },
                  "xcl_chocolateenrober":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_chocolatetruffles"
                  },
                  "xcl_masterbaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_vanillaglazedonut"
                  },
                  "xcl_bigblender":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_mintchocochipmilkshake"
                  },
                  "xcl_candycreator":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_strawberrymilkcandy"
                  },
                  "xcl_icecreammaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcl_strawberrysoftserve"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"candyfactoryAnimals1":{"complete":false}};
               break;
            case SYSTEM_XID_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"irishstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xid_wetclay":2,
                        "xid_claddaghring":2,
                        "xid_irishjug":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xid_fourleafcloverbush",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"squirrel_xid_pikeman",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xid_oldmine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_rawmetal"
                  },
                  "xid_claypit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_wetclay"
                  },
                  "xid_wooldropspindle":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_spoolofyarn"
                  },
                  "xid_tanningrack":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_curedleather"
                  },
                  "xid_lumberyard":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_boardsoftimber"
                  },
                  "xid_oldfurnace":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_ironingot"
                  },
                  "xid_wheatgringstone":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_freshflour"
                  },
                  "xid_metalworks":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_claddaghring"
                  },
                  "xid_potterytable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_irishjug"
                  },
                  "xid_woolenloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_irishcrios"
                  },
                  "xid_leatherworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_irishbelt"
                  },
                  "xid_carpentry":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_irishmether"
                  },
                  "xid_metalsmith":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_ironhorseshoe"
                  },
                  "xid_cookingpot":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xid_traditionalirishstew"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"irishstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XHF_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"jackostableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xhf_rolledcoir":2,
                        "xhf_demonstatue":2,
                        "xhf_darknightmat":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xhf_spookyhaybale",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"rabbit_xhf_dracula",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xhf_mudplot":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_clayblock"
                  },
                  "xhf_coirwood":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_rolledcoir"
                  },
                  "xhf_bulbfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_coloredbulbs"
                  },
                  "xhf_clothloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_clothroll"
                  },
                  "xhf_supermart":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_bakeryingredients"
                  },
                  "xhf_sugarmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_sugarcubes"
                  },
                  "xhf_pumpkinpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_pumpkinbasket"
                  },
                  "xhf_statuemaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_demonstatue"
                  },
                  "xhf_matsmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_darknightmat"
                  },
                  "xhf_electricianstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_spookybulbs"
                  },
                  "xhf_costumemaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_magiciancostume"
                  },
                  "xhf_oven":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_spideycupcake"
                  },
                  "xhf_candymachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_scarylicorice"
                  },
                  "xhf_carvingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xhf_nerdypumpkin"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"jackostableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XWS_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"toyhostableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xws_giftwrapper":2,
                        "xws_whitesnowballs":2,
                        "xws_shoegiftbox":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xws_wrappedcandycane",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xws_rudolphsnail",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xws_snowmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_snowpowder"
                  },
                  "xws_giftwrapstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_giftwrapper"
                  },
                  "xws_candymachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_christmascandies"
                  },
                  "xws_woolmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_polarwool"
                  },
                  "xws_christmastreefarm":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_decorativetree"
                  },
                  "xws_printingpress":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_greetingpaper"
                  },
                  "xws_specialchest":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_colorfulornaments"
                  },
                  "xws_snowstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_whitesnowballs"
                  },
                  "xws_giftstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_shoegiftbox"
                  },
                  "xws_candystation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_snowmasonjar"
                  },
                  "xws_clothshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_ornamentbag"
                  },
                  "xws_christmastreeshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_minisnowtrees"
                  },
                  "xws_greetingcardshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_floralcard"
                  },
                  "xws_ornamentshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xws_hohohoornament"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"toyhostableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XFS_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"greenhousestableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xfs_metalbars":2,
                        "xfs_grilledcorn":2,
                        "xfs_organicicecream":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xfs_flowerwatercan",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"horse_xfs_hydroponics",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xfs_farmingpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_vegetableharvest"
                  },
                  "xfs_metalblock":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_metalbars"
                  },
                  "xfs_cornpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_cornpack"
                  },
                  "xfs_woodenlogs":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_woodenpieces"
                  },
                  "xfs_cottonpatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_clothrolls"
                  },
                  "xfs_seedmill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_seedbucket"
                  },
                  "xfs_dairyshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_curdbowl"
                  },
                  "xfs_foodstall":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_grilledcorn"
                  },
                  "xfs_toolstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_organicicecream"
                  },
                  "xfs_popcornshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_farmscythe"
                  },
                  "xfs_toymaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_freshcaramelpopcorn"
                  },
                  "xfs_tailorbench":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_woodentoyscarecrow"
                  },
                  "xfs_seedshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_ruggedpants"
                  },
                  "xfs_yogurtmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xfs_blueberryorganicyogurt"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"greenhousestableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XMT_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"malagasystableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xmt_cotton":2,
                        "xmt_plainjanemask":2,
                        "xmt_bellybasket":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xmt_oldrooftiles",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"chipmunk_xmt_cocoa",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xmt_woodchopper":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_wood"
                  },
                  "xmt_cottonspinner":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_cotton"
                  },
                  "xmt_fiberpress":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_fiber"
                  },
                  "xmt_vanillapodsplitter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_vanilla"
                  },
                  "xmt_coffeebeanmixer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_coffee"
                  },
                  "xmt_shellfishsorter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_shellfish"
                  },
                  "xmt_gemstonecutter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_gemstones"
                  },
                  "xmt_sculptingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_plainjanemask"
                  },
                  "xmt_textilestore":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_bellybasket"
                  },
                  "xmt_outfitmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_madagascarscarf"
                  },
                  "xmt_dessertcabinet":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_vanillacustardbite"
                  },
                  "xmt_cafe":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_espressoswig"
                  },
                  "xmt_decortable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_seashellvase"
                  },
                  "xmt_jewelrystation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xmt_scarletring"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"malagasystableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XBB_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"sandyshorestableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xbb_pandanusleaves":2,
                        "xbb_ropelamp":2,
                        "xbb_pineappleperfume":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xbb_glasspanels",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"horse_xbb_floraltraveller",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xbb_treebark":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_barkcloth"
                  },
                  "xbb_boraboratrees":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_pandanusleaves"
                  },
                  "xbb_tropicalfruits":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_tropicaljuices"
                  },
                  "xbb_lumbermill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_lumber"
                  },
                  "xbb_flowerbed":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_freshflowers"
                  },
                  "xbb_coconuts":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_coconutfibre"
                  },
                  "xbb_pearlshells":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_boraborapearls"
                  },
                  "xbb_tropicalgiftshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_ropelamp"
                  },
                  "xbb_perfumemaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_pineappleperfume"
                  },
                  "xbb_beachbar":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_bluelemonadepitcher"
                  },
                  "xbb_woodcrafter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_palmtreelantern"
                  },
                  "xbb_flowermarket":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_tropicalflowercollection"
                  },
                  "xbb_fibresewingmachine":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_strawcrown"
                  },
                  "xbb_tropicaljewelryshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xbb_weddingearrings"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"sandyshorestableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XDM_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"classicdutchstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xdm_flowers":2,
                        "xdm_delftvase":2,
                        "xdm_soccerball":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xdm_texturedglass",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"squirrel_xdm_hollandwindmill",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xdm_claypit":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_clayblocks"
                  },
                  "xdm_flowerspatch":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_flowers"
                  },
                  "xdm_threadloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_threadsspool"
                  },
                  "xdm_leatherpress":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_leatherstrip"
                  },
                  "xdm_glassfurnace":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_rawglass"
                  },
                  "xdm_floormill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_rawflour"
                  },
                  "xdm_woodcutter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_rawwood"
                  },
                  "xdm_potterstable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_delftvase"
                  },
                  "xdm_leatherworkingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_soccerball"
                  },
                  "xdm_flowershop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_tulipbulbs"
                  },
                  "xdm_clothloom":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_dutchhat"
                  },
                  "xdm_bakeryshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_goudawheel"
                  },
                  "xdm_carpenterstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_woodenclogs"
                  },
                  "xdm_glassworkerstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xdm_glassmarble"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"classicdutchstableAnimal1":{"complete":false}};
               break;
            default:
               data = null;
               break;
            case SYSTEM_XCD_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"hillsidestableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xcd_custompaper":2,
                        "xcd_pinewooddesk":2,
                        "xcd_postalenvelope":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xcd_mountainstone",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xcd_rubycollaredpika",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xcd_choppingblock":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_pinewoodround"
                  },
                  "xcd_papermill":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_custompaper"
                  },
                  "xcd_grainmixer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_ciderwheat"
                  },
                  "xcd_ironcast":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_vancouveriron"
                  },
                  "xcd_mapledistillery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_sugarmaple"
                  },
                  "xcd_handloomspinner":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_canadiancotton"
                  },
                  "xcd_ceramicshaper":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_naturalceramic"
                  },
                  "xcd_woodcuttingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_pinewooddesk"
                  },
                  "xcd_papercraftshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_postalenvelope"
                  },
                  "xcd_breadbakery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_rieloaf"
                  },
                  "xcd_ironworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_ironbicycle"
                  },
                  "xcd_dessertcounter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_maplecandy"
                  },
                  "xcd_clothfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_mountainearmuffs"
                  },
                  "xcd_sculptingcenter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xcd_sugarjar"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"hillsidestableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XAH_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"pacificstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xah_hawaiikoawood":2,
                        "xah_wovenleafwreath":2,
                        "xah_hawaiibeachchair":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xah_bananaleafcloth",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"genanimal_xah_oahutreesnail",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xah_leafcollector":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_tropicleaves"
                  },
                  "xah_woodcollector":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_hawaiikoawood"
                  },
                  "xah_strawmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_ricestraw"
                  },
                  "xah_kapamaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_kapa"
                  },
                  "xah_fruitmarket":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_assortedfruits"
                  },
                  "xah_stonecollector":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_beautystones"
                  },
                  "xah_crystalcollector":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_shinycrystal"
                  },
                  "xah_leafweaverstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_wovenleafwreath"
                  },
                  "xah_tropicalfurniturestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_hawaiibeachchair"
                  },
                  "xah_constructionstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_tropicaltikihut"
                  },
                  "xah_tropicalclothingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_bluehawaiianshirt"
                  },
                  "xah_tropicalfruitsstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_fruitsalad"
                  },
                  "xah_antiquestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_vintagepoibowl"
                  },
                  "xah_tropicaljewelerystation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xah_crystalcarvedflower"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"pacificstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XPU_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"pumpkinfarmstableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xpu_brownsugarblocks":2,
                        "xpu_happypumpkin":2,
                        "xpu_caramelbites":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xpu_scarytiles",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"squirrel_xpu_magician",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xpu_pumpkinchopper":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_lanternpumpkin"
                  },
                  "xpu_caramelmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_brownsugarblocks"
                  },
                  "xpu_cottonsifter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_eggshellcotton"
                  },
                  "xpu_chocolatemolder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_cocoabeans"
                  },
                  "xpu_accessorymaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_rainbowbeads"
                  },
                  "xpu_hatmaker":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_clothroll"
                  },
                  "xpu_ironmolder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_heavyiron"
                  },
                  "xpu_pumpkincounter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_happypumpkin"
                  },
                  "xpu_candytable":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_caramelbites"
                  },
                  "xpu_costumestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_witchcostume"
                  },
                  "xpu_chocolatestation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_chocolaterocks"
                  },
                  "xpu_accessoryfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_wizardbroomstick"
                  },
                  "xpu_hatstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_bathat"
                  },
                  "xpu_cauldronfactory":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xpu_antiquecauldron"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"pumpkinfarmstableAnimal1":{"complete":false}};
               break;
            case SYSTEM_XYT_ELITEHORSES:
               data[DATAKEY_STORAGE] = {
                  "ingredient":{"level":3},
                  "recipe":{"level":2}
               };
               data[DATAKEY_GOODS] = {};
               data[DATAKEY_ORDERBOARD] = {"holidayjoystableAnimal1":{
                  "completeNowPrice":16,
                  "orders":[{
                     "goods":{
                        "xyt_mountainglass":2,
                        "xyt_hallstattdesk":2,
                        "xyt_xmasdinnerset":1
                     },
                     "rewards":[{
                        "type":REWARDS_TYPE_POINTS,
                        "amount":0
                     },{
                        "type":REWARDS_TYPE_COIN,
                        "amount":1000
                     }],
                     "helperId":-1,
                     "complete":false
                  }],
                  "rewards":[{
                     "type":REWARDS_TYPE_POINTS,
                     "amount":5
                  },{
                     "type":REWARDS_TYPE_COIN,
                     "amount":5000
                  },{
                     "type":REWARDS_TYPE_INVENTORYPARTS,
                     "value":"part_xyt_christmasbarrel",
                     "amount":2
                  },{
                     "type":REWARDS_TYPE_ITEMGRANT,
                     "value":"mouse_xyt_winterharvest",
                     "amount":1
                  }]
               }};
               data[DATAKEY_MASTERY] = {};
               data[DATAKEY_STATIONS] = {
                  "xyt_woodsplitter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_viennawood"
                  },
                  "xyt_glassmolder":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_mountainglass"
                  },
                  "xyt_woolcollector":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_austrianwool"
                  },
                  "xyt_sugardistillery":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_harvestsugar"
                  },
                  "xyt_ironsmelter":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_pineconeiron"
                  },
                  "xyt_cottongatherer":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_hillsidecotton"
                  },
                  "xyt_bronzepolisher":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_antiquebronze"
                  },
                  "xyt_sculptingstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_hallstattdesk"
                  },
                  "xyt_glasswareworkshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_xmasdinnerset"
                  },
                  "xyt_sweaterspinner":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_christmassweater"
                  },
                  "xyt_sweetshopstation":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_linzertorte"
                  },
                  "xyt_snowtoolshop":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_sidewalkscraper"
                  },
                  "xyt_holidayboutique":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_viennamittens"
                  },
                  "xyt_antiquesshowcase":{
                     "active":true,
                     "startTime":0,
                     "recipe":"xyt_grandfatherclock"
                  }
               };
               data[DATAKEY_POINTS] = 0;
               data[DATAKEY_NPCS] = {"holidayjoystableAnimal1":{"complete":false}};
         }
         return data;
      }
      
      public function get location() : String
      {
         return this.m_location;
      }
      
      public function get whatisThisPrefix() : String
      {
         return this.m_whatisThisPrefix;
      }
      
      public function get bonusAnimal() : String
      {
         return this.m_bonusAnimal;
      }
   }
}

