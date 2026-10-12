package Managers.Crafting
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.ToasterIconPaths;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ConstructionBuilding;
   import Classes.Consumable;
   import Classes.CraftConfigSettings;
   import Classes.CraftingCottageBuilding;
   import Classes.FeatureBuilding;
   import Classes.Friend;
   import Classes.Idle.Crafting.CraftingBushelSummaryTask;
   import Classes.Idle.Crafting.CraftingCottageRecipeReadyTask;
   import Classes.Idle.Crafting.CraftingImpulseBuyTask;
   import Classes.MarketStallBuilding;
   import Classes.Mastery;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.RecipeMasterySign;
   import Classes.SmartSystemData;
   import Classes.StorageInventoryType;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.SeedItem;
   import Classes.buffs.BBushel;
   import Classes.crafting.BushelsFoundSummary;
   import Classes.crafting.CraftLevel;
   import Classes.crafting.CraftSpecialization;
   import Classes.crafting.CraftTypeState;
   import Classes.crafting.CraftingFeed;
   import Classes.crafting.CraftingInventoryStateV2;
   import Classes.crafting.CraftingSkillState;
   import Classes.crafting.CraftingStatsManager;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.PendingReward;
   import Classes.crafting.RecipeItem;
   import Classes.crafting.RecipeState;
   import Classes.crafting.ShoppingState;
   import Classes.feed.CraftingCottageFeed;
   import Classes.feed.CraftshopFeed;
   import Classes.feed.MarketThankYouFeed;
   import Classes.feed.ShareMarketStallFeed;
   import Classes.storage.CraftedItem;
   import Classes.storage.StorageItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.GenericIconPopup;
   import Display.GenericObjectPreviewPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import GameMode.GMBuild;
   import Managers.DailyStatsManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.HangingGardensManager;
   import Managers.LabBuildingManager;
   import Managers.ToasterManager;
   import Transactions.TBeginRecipe;
   import Transactions.TBuyBushel;
   import Transactions.TBuyBushelBundle;
   import Transactions.TBuyCraftedGood;
   import Transactions.TBuyRecipeRush;
   import Transactions.TCancelFriendReward;
   import Transactions.TCancelRecipe;
   import Transactions.TClaimFinishedRecipes;
   import Transactions.TClaimFreeCottage;
   import Transactions.TClaimMarketReward;
   import Transactions.TClaimMarketStallItem;
   import Transactions.TCloseMarketStall;
   import Transactions.TCraftBuyUpgrade;
   import Transactions.TCraftInstantRecipe;
   import Transactions.TExchangeBushels;
   import Transactions.TGenericTransactionWithFeed;
   import Transactions.TGetBushelRequestFeed;
   import Transactions.TGetMarketStallRewardUrl;
   import Transactions.TReconfigureMarketStall;
   import Transactions.TSetCraftedGoodPrice;
   import Transactions.TShareBushels;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.Crafting.BushelInfoWindow;
   import Widgets.Windows.Crafting.ChooseCottageWindow;
   import Widgets.Windows.Crafting.CraftshopWindow;
   import Widgets.Windows.Crafting.FirstCraftingSiloWindow;
   import Widgets.Windows.Crafting.FirstMarketStallWindow;
   import Widgets.Windows.Crafting.HangingGardensCraftingShopWindow;
   import Widgets.Windows.Crafting.PizzashopWindow;
   import Widgets.Windows.Crafting.PurchaseBushelBundles;
   import Widgets.Windows.Crafting.RecipeMasteryOnBoard;
   import Widgets.Windows.Crafting.RecipeMasteryWindow;
   import Widgets.Windows.Crafting.ReconfigureStallWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import ZLocalization.LocalizationObjectToken;
   import ZLocalization.Utilities;
   import ZQuest.Init.QuestSettingsInit;
   import com.adobe.utils.ArrayUtil;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class CraftingManager
   {
      
      private static var m_instance:CraftingManager;
      
      public static const YULETIDE_CRAFTSHOP_NAME:String = "xyt_craftshop_finished";
      
      public static const PUMPKIN_CRAFTSHOP_NAME:String = "xpu_craftshop_finished";
      
      public static const NO_MARKET_STALL_ROOM:int = -1;
      
      public static const NO_CRAFTING_SILO_ROOM:int = -2;
      
      public static const NO_UNSHARABLE_INVENTORY_ROOM:int = -3;
      
      public static const DEFAULT_RECIPE_BUNDLE_PRICE:int = 3;
      
      public static const DEFAULT_BUSHEL_PRICE:int = 1;
      
      public static const BUSHEL_TYPE_STALL:int = 0;
      
      public static const BUSHEL_TYPE_SILO:int = 1;
      
      public static const BUSHEL_TYPE_LAB:int = 2;
      
      public static const BUSHEL_TYPE_UNSHARABLE:int = 3;
      
      public static const MARKET_STALL_ITEM_CODE:String = "ms";
      
      public static const BUSHEL_TYPE_VILLAGE:int = 4;
      
      public static const CRAFTING_BUSHEL_SUBTYPE_LAB:String = "lab";
      
      public static const CRAFTING_BUSHEL_SUBTYPE_SILO_ANIMAL:String = "animal";
      
      public static const CRAFTING_BUSHEL_SUBTYPE_SILO_TREE:String = "tree";
      
      public static const CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE:String = "unsharable";
      
      public static const CRAFTING_BUSHEL_SUBTYPE_VILLAGE:String = "village";
      
      public static const MAIN_CRAFTSHOP_NAME:String = "craftingworkshop_finished";
      
      public static const XAL_CRAFTSHOP_NAME:String = "xalcraftingworkshop_finished";
      
      public static const HG_CRAFTSHOP_NAME:String = "xhgcraftingcottage";
      
      public static const SPACE_CRAFTSHOP_NAME:String = "xspcraftingworkshop_finished";
      
      public static const CANDY_CRAFTSHOP_NAME:String = "xcwcraftingworkshop_finished";
      
      public static const HLIGHTS_CRAFTSHOP_NAME:String = "xlgcraftingworkshop_finished";
      
      public static const RAINFOREST_CRAFTSHOP_NAME:String = "xrfcraftingworkshop_finished";
      
      public static const OZ_CRAFTSHOP_NAME:String = "xozcraftingshop_finished";
      
      public static const MEDITERRANEAN_CRAFTSHOP_NAME:String = "xmdcraftingshop_finished";
      
      public static const OASIS_CRAFTSHOP_NAME:String = "xoa_oasiscraftshop_finished";
      
      public static const STORYBOOK_CRAFTSHOP_NAME:String = "xsb_craftshop_finished";
      
      public static const SLEEPYHOLLOW_CRAFTSHOP_NAME:String = "xsh_craftshop_finished";
      
      public static const TOYLAND_CRAFTSHOP_NAME:String = "xtl_craftshop_finished";
      
      public static const AVALON_CRAFTSHOP_NAME:String = "xma_craftshop_finished";
      
      public static const WILDWEST_CRAFTSHOP_NAME:String = "xwa_wildwestcraftshop_finished";
      
      public static const TREASURETIDES_CRAFTSHOP_NAME:String = "xsa_tidescraftshop_finished";
      
      public static const AFRICA_CRAFTSHOP_NAME:String = "xaf_savannahcraftshop_finished";
      
      public static const TRANSYLVANIA_CRAFTSHOP_NAME:String = "xtr_craftshop_finished";
      
      public static const WINTER_CRAFTSHOP_NAME:String = "xwi_craftshop_finished";
      
      public static const JAPAN_CRAFTSHOP_NAME:String = "xjp_craftshop_finished";
      
      public static const INDIA_CRAFTSHOP_NAME:String = "xin_craftshop_finished";
      
      public static const JUNGLE_CRAFTSHOP_NAME:String = "xjm_craftshop_finished";
      
      public static const MOUNT_CRAFTSHOP_NAME:String = "xmo_craftshop_finished";
      
      public static const LIMBO_CRAFTSHOP_NAME:String = "xbo_craftshop_finished";
      
      public static const XMAS_CRAFTSHOP_NAME:String = "xch_craftshop_finished";
      
      public static const AUSTRALIA_CRAFTSHOP_NAME:String = "xau_craftshop_finished";
      
      public static const HAWAII_CRAFTSHOP_NAME:String = "xhi_craftshop_finished";
      
      public static const MIDWEST_CRAFTSHOP_NAME:String = "xhh_craftshop_finished";
      
      public static const TURTLEISLAND_CRAFTSHOP_NAME:String = "xti_craftshop_finished";
      
      public static const DREAMWORLD_CRAFTSHOP_NAME:String = "xdw_craftshop_finished";
      
      public static const ANGLOFRENCH_CRAFTSHOP_NAME:String = "xfe_craftshop_finished";
      
      public static const HALLOWEENUSA_CRAFTSHOP_NAME:String = "xha_craftshop_finished";
      
      public static const TUSCANY_CRAFTSHOP_NAME:String = "xty_craftshop_finished";
      
      public static const CARIBBEAN_CRAFTSHOP_NAME:String = "xcb_craftshop_finished";
      
      public static const DRAGONVALLEY_CRAFTSHOP_NAME:String = "xdv_craftshop_finished";
      
      public static const WHITEWINTER_CRAFTSHOP_NAME:String = "xfw_craftshop_finished";
      
      public static const BRAZIL_CRAFTSHOP_NAME:String = "xbr_craftshop_finished";
      
      public static const UNDERWATER_CRAFTSHOP_NAME:String = "xuw_craftshop_finished";
      
      public static const RUSSIA_CRAFTSHOP_NAME:String = "xru_craftshop_finished";
      
      public static const NEWFRONTIER_CRAFTSHOP_NAME:String = "xnf_craftshop_finished";
      
      public static const ISRAEL_CRAFTSHOP_NAME:String = "xis_craftshop_finished";
      
      public static const HALLOWEENMAD_CRAFTSHOP_NAME:String = "xhx_craftshop_finished";
      
      public static const WINTERNORD_CRAFTSHOP_NAME:String = "xwx_craftshop_finished";
      
      public static const CASABLANCA_CRAFTSHOP_NAME:String = "xca_craftshop_finished";
      
      public static const SOUTHINDIA_CRAFTSHOP_NAME:String = "xbl_craftshop_finished";
      
      public static const TWENTIES_CRAFTSHOP_NAME:String = "xrt_craftshop_finished";
      
      public static const ALASKA_CRAFTSHOP_NAME:String = "xsu_craftshop_finished";
      
      public static const COCOLAND_CRAFTSHOP_NAME:String = "xcl_craftshop_finished";
      
      public static const IRELAND_CRAFTSHOP_NAME:String = "xid_craftshop_finished";
      
      public static const SPOOKY_CRAFTSHOP_NAME:String = "xhf_craftshop_finished";
      
      public static const SANTAVILLAGE_CRAFTSHOP_NAME:String = "xws_craftshop_finished";
      
      public static const FARMFEST_CRAFTSHOP_NAME:String = "xfs_craftshop_finished";
      
      public static const MADAGASCAR_CRAFTSHOP_NAME:String = "xmt_craftshop_finished";
      
      public static const BORABORA_CRAFTSHOP_NAME:String = "xbb_craftshop_finished";
      
      public static const AMSTERDAM_CRAFTSHOP_NAME:String = "xdm_craftshop_finished";
      
      public static const CANADA_CRAFTSHOP_NAME:String = "xcd_craftshop_finished";
      
      public static const ALOHA_CRAFTSHOP_NAME:String = "xah_craftshop_finished";
      
      public static const KEY_SMART_SYSTEM_MULTIPLIER:String = "multiplier";
      
      public static const KEY_SMART_SYSTEM_ACTUAL_BUCKET:String = "actualBucket";
      
      public static const KEY_SMART_SYSTEM_ASSIGNED_BUCKET:String = "assignedBucket";
      
      private static var m_tBuyCraftedGood:TBuyCraftedGood = null;
      
      public static const GIFTBOX_BLACKLIST_CLASSNAMES:Array = ["FeatureCraftingAutoConsumable","EliteHorsesAutoConsumable","CraftableCurrencyItem"];
      
      public static const CRAFTING_COTTAGE_POPUP_OFFSET_X:int = 0;
      
      public static const CRAFTING_COTTAGE_POPUP_OFFSET_Y:int = -40;
      
      private const EXPIRING_RECIPE_BUFFER_MS:int = 259200000;
      
      private const FEED_BUNDLE_ID_SHARE_HARVEST_BUSHEL:String = "craftingsilo_shareharvestbushel";
      
      public const MARKET_STALL_EXPAND_SHOWN:String = "market_expand_shown";
      
      public const SMART_CRAFTING_CRAFT_SHOP_TUNING_TABLE:String = "smart_crafting_craft_shop";
      
      public const SMART_CRAFTING_CRAFTING_COTTAGE_TUNING_TABLE:String = "smart_crafting_crafting_cottage";
      
      private var m_sharedFullFeedBushels:int = 0;
      
      private var m_sharedFullFeedBushelCode:String = "";
      
      private var m_sharedFullRewardUrl:String = "";
      
      private var m_popupCount:int = 0;
      
      private var m_bushelsFoundSummaryQueue:Array = new Array();
      
      private var m_siloBushelDialogSummaryQueue:Array = new Array();
      
      private var m_reconfigurePopupsShown:Array = new Array();
      
      private var m_hasHiddenArrows:Boolean = false;
      
      private var m_hasSeenRewardsPopup:Boolean = false;
      
      private var m_hasSeenImpulseBuyPopup:Boolean = false;
      
      private var m_reconfigureOnPlace:Boolean = false;
      
      private var m_lastBushelFound:String;
      
      private var m_bushelInfoWindow:BushelInfoWindow;
      
      private var m_closePurchaseDialogCallback:Function;
      
      private var m_purchaseDialogCallback:Function;
      
      private var m_craftPreorderRewardUrl:String;
      
      private var m_freeCottageWindowShown:Boolean;
      
      private var m_showPlaceCottageReminderOnLoad:Boolean = false;
      
      private var m_craftingReminderSource:String = null;
      
      private var m_buyGoodsResponse:Object = null;
      
      private var m_buyGoodsFromUserId:String;
      
      private var m_buyGoodsShare:Boolean = false;
      
      private var m_inTutorialMode:Boolean = false;
      
      private var m_expansionDialog:GenericDialog = null;
      
      private var m_expansionDialogCallback:Function = null;
      
      private var m_craftshopRecipeIds:Object = new Object();
      
      private var m_craftshopRecipeNames:Object = new Object();
      
      private var m_craftshopValidRecipesIds:Object = new Object();
      
      private var m_lastFilterSearchStringObject:Object = new Object();
      
      private var m_filteredRecipeIds:Object = new Object();
      
      protected var m_bushels:Dictionary;
      
      public function CraftingManager()
      {
         super();
      }
      
      public static function getCraftShopNameForCurrentWorld(worldName:String) : String
      {
         var craftshopName:String = MAIN_CRAFTSHOP_NAME;
         switch(worldName)
         {
            case WorldsConstants.WORLD_ID_ANGLER:
               craftshopName = "";
               break;
            case WorldsConstants.WORLD_ID_ATLANTIS:
               craftshopName = XAL_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_GARDEN:
               craftshopName = HG_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_SPACE:
               craftshopName = SPACE_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_CANDY:
               craftshopName = CANDY_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_HLIGHTS:
               craftshopName = HLIGHTS_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_RAINFOREST:
               craftshopName = RAINFOREST_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_OZ:
               craftshopName = OZ_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_MEDITERRANEAN:
               craftshopName = MEDITERRANEAN_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_OASIS:
               craftshopName = OASIS_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_STORYBOOK:
               craftshopName = STORYBOOK_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_SLEEPYHOLLOW:
               craftshopName = SLEEPYHOLLOW_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_TOYLAND:
               craftshopName = TOYLAND_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_AVALON:
               craftshopName = AVALON_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_WILDWEST:
               craftshopName = WILDWEST_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_TREASURETIDES:
               craftshopName = TREASURETIDES_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_AFRICA:
               craftshopName = AFRICA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_TRANSYLVANIA:
               craftshopName = TRANSYLVANIA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_HAWAII:
               craftshopName = AUSTRALIA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_HAWAII:
               craftshopName = HAWAII_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_WINTER:
               craftshopName = WINTER_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_JAPAN:
               craftshopName = JAPAN_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_INDIA:
               craftshopName = INDIA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_JUNGLE:
               craftshopName = JUNGLE_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_MOUNT:
               craftshopName = MOUNT_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_LIMBO:
               craftshopName = LIMBO_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_XMAS:
               craftshopName = XMAS_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_MIDWEST:
               craftshopName = MIDWEST_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_TURTLEISLAND:
               craftshopName = TURTLEISLAND_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_UNDERWATER:
               craftshopName = UNDERWATER_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_DREAMWORLD:
               craftshopName = DREAMWORLD_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_ANGLOFRENCH:
               craftshopName = ANGLOFRENCH_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENUSA:
               craftshopName = HALLOWEENUSA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_TUSCANY:
               craftshopName = TUSCANY_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_WHITEWINTER:
               craftshopName = WHITEWINTER_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_BRAZIL:
               craftshopName = BRAZIL_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_CARIBBEAN:
               craftshopName = CARIBBEAN_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_DRAGONVALLEY:
               craftshopName = DRAGONVALLEY_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_RUSSIA:
               craftshopName = RUSSIA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_NEWFRONTIER:
               craftshopName = NEWFRONTIER_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_ISRAEL:
               craftshopName = ISRAEL_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENMAD:
               craftshopName = HALLOWEENMAD_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_WINTERNORD:
               craftshopName = WINTERNORD_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_CASABLANCA:
               craftshopName = CASABLANCA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_SOUTHINDIA:
               craftshopName = SOUTHINDIA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_TWENTIES:
               craftshopName = TWENTIES_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_ALASKA:
               craftshopName = ALASKA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_COCOLAND:
               craftshopName = COCOLAND_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_IRELAND:
               craftshopName = IRELAND_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_SPOOKY:
               craftshopName = SPOOKY_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_SANTAVILLAGE:
               craftshopName = SANTAVILLAGE_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_FARMFEST:
               craftshopName = FARMFEST_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_MADAGASCAR:
               craftshopName = MADAGASCAR_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_BORABORA:
               craftshopName = BORABORA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_AMSTERDAM:
               craftshopName = AMSTERDAM_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_CANADA:
               craftshopName = CANADA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_ALOHA:
               craftshopName = ALOHA_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_PUMPKIN:
               craftshopName = PUMPKIN_CRAFTSHOP_NAME;
               break;
            case WorldsConstants.WORLD_ID_YULETIDE:
               craftshopName = YULETIDE_CRAFTSHOP_NAME;
         }
         return craftshopName;
      }
      
      public static function surfaceNewCraftShop(craftingBuildingName:String = null) : void
      {
         var craftshop:FeatureBuilding = null;
         var prompt:GenericXMLDialog = null;
         var message:String = null;
         var worldItems:Array = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
         if(worldItems.length > 0)
         {
            craftshop = worldItems[0];
            if(Boolean(craftshop) && (craftingBuildingName == null || craftshop.getItemName() == craftingBuildingName))
            {
               craftshop.displayStorageDialog();
            }
         }
         else if(craftingBuildingName != null && Global.player.level >= 15)
         {
            prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName(craftingBuildingName,"icon",false),100,100,ZLocUtils.t_pk("Dialogs:SurfaceCraftShop_Message"),null,true,ZLocUtils.t_pk("Dialogs:SurfaceCraftShop_Button"),function(event:Event):void
            {
               Global.world.enterForcePlaceMode(craftingBuildingName,true,0,false,false,{"suppressGiftRepop":true});
            });
            UI.displayPopup(prompt,true,"",true);
         }
         else
         {
            message = "Find the craftshop in the market";
            UI.displayMessage(message);
         }
         FarmStatsManager.count("EhButton","Craftshop","Click");
      }
      
      public static function shouldUseNewCraftshopInFeature(featureName:String) : Boolean
      {
         var shouldFeatureUseNewCraftshop:Boolean = true;
         switch(featureName)
         {
            case PizzashopWindow.PIZZASHOP_BUILDING:
            case HangingGardensCraftingShopWindow.HANGING_GARDENS:
               shouldFeatureUseNewCraftshop = false;
         }
         return shouldFeatureUseNewCraftshop;
      }
      
      public static function shouldShowCraftingIconForWorld(worldName:String) : Boolean
      {
         var shouldShowCraftingIconForWorld:Boolean = true;
         switch(worldName)
         {
            case WorldsConstants.WORLD_ID_GARDEN:
               shouldShowCraftingIconForWorld = false;
         }
         return shouldShowCraftingIconForWorld;
      }
      
      public static function getBushelFromItemName(itemName:String) : FarmItem
      {
         var result:FarmItem = null;
         var harvestableObject:HarvestableItem = Global.farmGameSettingsManager.getFarmItemByName(itemName) as HarvestableItem;
         if(Boolean(harvestableObject) && Boolean(harvestableObject.bushelItemCode))
         {
            result = Global.farmGameSettingsManager.getFarmItemByCode(harvestableObject.bushelItemCode);
         }
         return result;
      }
      
      public static function handleBushelFound(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("foundBushel"))
         {
            CraftingManager.getInstance().recordBushelFound(result);
         }
      }
      
      public static function sortRecipesBy(recipeData:Array, field:String, sortDirection:String = "", bubbleRecipesOfTheWeek:Boolean = true) : Array
      {
         var craftshopRecipe:Object = null;
         var useNumeric:Boolean = false;
         var currentRecipeId:String = null;
         var recipeItem:RecipeItem = null;
         var name:String = null;
         var timeToCook:int = 0;
         var startDate:String = null;
         var recipeObject:Object = null;
         var result:Array = new Array();
         var recipesOfTheWeek:Array = new Array();
         for each(craftshopRecipe in recipeData)
         {
            currentRecipeId = craftshopRecipe.recipeId;
            recipeItem = Global.craftConfigSettings.getRecipeById(currentRecipeId);
            name = recipeItem.friendlyTitle;
            timeToCook = recipeItem.secondsToCook;
            startDate = recipeItem.limitedStartDate;
            recipeObject = {
               "name":name,
               "craftTimeasc":timeToCook,
               "craftTimedesc":timeToCook,
               "startDate":startDate,
               "recipeId":currentRecipeId
            };
            if(bubbleRecipesOfTheWeek && recipeItem.isRecipeOfTheWeek())
            {
               recipesOfTheWeek.push(recipeObject);
            }
            else
            {
               result.push(recipeObject);
            }
         }
         useNumeric = field == "craftTimeasc" || field == "craftTimedesc";
         switch(sortDirection)
         {
            case "desc":
               if(useNumeric)
               {
                  result.sortOn(field,Array.DESCENDING | Array.NUMERIC);
               }
               else
               {
                  result.sortOn(field,Array.DESCENDING);
               }
               break;
            default:
               if(useNumeric)
               {
                  result.sortOn(field,Array.NUMERIC);
               }
               else
               {
                  result.sortOn(field);
               }
         }
         if(recipesOfTheWeek.length > 0)
         {
            if(recipesOfTheWeek.length > 1)
            {
               recipesOfTheWeek = sortRecipesBy(recipesOfTheWeek,"startDate","desc",false);
            }
            result.unshift.apply(result,recipesOfTheWeek);
         }
         return result;
      }
      
      public static function getValidRecipeFromCategory(category:String) : String
      {
         var recipeCode:String = null;
         var recipe:RecipeItem = null;
         var result:String = null;
         var itemCodes:Array = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemCodesInCategory(category);
         for each(recipeCode in itemCodes)
         {
            recipe = Global.craftConfigSettings.getRecipeById(recipeCode);
            if(isRecipeValid(recipe))
            {
               result = recipeCode;
               break;
            }
         }
         return result;
      }
      
      private static function isRecipeValid(recipeItem:RecipeItem) : Boolean
      {
         return recipeItem.isLimitedValid() && recipeItem.isPlayerEligible() && recipeItem.isEndDateValid() && recipeItem.isStartDateValid();
      }
      
      public static function getInProgressRecipeHash(craftType:String) : Object
      {
         var recipeInProgress:RecipeItem = null;
         var recipesInProgress:Array = CraftingRecipeQueueManager.getInstanceByCraftType(craftType).recipeQueue;
         var inProgressRecipeIdHash:Object = {};
         var arrLength:int = int(recipesInProgress.length);
         for(var i:int = 0; i < arrLength; i++)
         {
            recipeInProgress = recipesInProgress[i] as RecipeItem;
            if(Boolean(recipeInProgress != null) && Boolean(recipeInProgress.id) && recipeInProgress.worldType == Global.worldManager.currentWorldType)
            {
               inProgressRecipeIdHash[recipeInProgress.id] = 1;
            }
         }
         return inProgressRecipeIdHash;
      }
      
      private static function renderBushelFoundStatus(bushelItemCode:String) : void
      {
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
         var status:String = ZLocUtils.t("Crafting","General_BushelFound",{"item":ZLocUtils.tk_pk(bushelItem.friendlyName)});
         var tweenDuration:Number = UI.DEFAULT_STATUS_TWEEN_DURATION;
         var tweenDisplacement:int = UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT;
         var iconUrl:String = bushelItem.icon;
         var iconFilters:Array = null;
         Global.player.avatar.displayStatus(status,iconUrl,iconFilters,tweenDuration,tweenDisplacement);
      }
      
      public static function getRecipeItemFromId(recipeId:String, craftType:String) : RecipeItem
      {
         var recipeQueue:Array = null;
         var recipeQueueLength:int = 0;
         var recipeQueueIndex:int = 0;
         var result:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         if(!HangingGardensManager.isInHangingGardensExperiment())
         {
            recipeQueue = Global.player.craftingState.getRecipeQueueForCraftType(craftType);
            recipeQueueLength = int(recipeQueue.length);
            for(recipeQueueIndex = 0; recipeQueueIndex < recipeQueueLength; recipeQueueIndex++)
            {
               if(recipeQueue[recipeQueueIndex].id == recipeId && (recipeQueue[recipeQueueIndex] as RecipeItem).worldType == Global.worldManager.currentWorldType)
               {
                  result = recipeQueue[recipeQueueIndex];
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getRecipeItemFromIdAndSlot(recipeId:String, slot:int, craftType:String) : RecipeItem
      {
         var result:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var recipeQueue:Array = Global.player.craftingState.getRecipeQueueForCraftType(craftType);
         var recipeQueueLength:int = int(recipeQueue.length);
         for(var recipeQueueIndex:int = 0; recipeQueueIndex < recipeQueueLength; recipeQueueIndex++)
         {
            if(recipeQueue[recipeQueueIndex].id == recipeId && recipeQueue[recipeQueueIndex].ovenSlot == slot && (recipeQueue[recipeQueueIndex] as RecipeItem).worldType == Global.worldManager.currentWorldType)
            {
               result = recipeQueue[recipeQueueIndex];
            }
         }
         return result;
      }
      
      public static function getNumBushelsOfSubtypeInQueues(bushelSubtype:String) : int
      {
         var craftType:String = null;
         var craftVersion:int = 0;
         var recipeQueue:Array = null;
         var recipeItem:RecipeItem = null;
         var farmItem:FarmItem = null;
         var allCraftTypes:Array = Global.craftConfigSettings.getAllCraftTypes();
         var numBushelsBeingMade:int = 0;
         for each(craftType in allCraftTypes)
         {
            craftVersion = Global.craftConfigSettings.getCraftVersion(craftType);
            if(craftVersion == CraftConfigSettings.CRAFT_VERSION_CRAFTSHOP)
            {
               recipeQueue = Global.player.craftingState.getRecipeQueueForCraftType(craftType);
               for each(recipeItem in recipeQueue)
               {
                  recipeItem = Global.craftConfigSettings.getRecipeById(recipeItem.id);
                  if(recipeItem.rewardsModern.hasOwnProperty(QuestConstants.REWARD_GRANT_BUSHEL_ITEM) && recipeItem.rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM] != null)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByCode(recipeItem.rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM].@value);
                     if(farmItem != null && farmItem.type == FarmItemType.BUSHEL && farmItem.subType == bushelSubtype)
                     {
                        if(recipeItem.rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM].@value != null)
                        {
                           numBushelsBeingMade += recipeItem.rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM].@quantity;
                        }
                        else
                        {
                           numBushelsBeingMade++;
                        }
                     }
                  }
               }
            }
         }
         return numBushelsBeingMade;
      }
      
      public static function canMakeRecursiveRecipe(recipeItem:RecipeItem) : Boolean
      {
         var rewardsList:XML = null;
         var result:Boolean = false;
         var itemCode:String = null;
         if(Global.player.craftingState.inventoryState.numUnsharableBushels + getNumBushelsOfSubtypeInQueues(CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE) < CraftingInventoryStateV2.MAX_UNSHARABLE_BUSHEL_CAPACITY)
         {
            if(recipeItem.rewardsModern.hasOwnProperty(QuestConstants.REWARD_GRANT_BUSHEL_ITEM) && recipeItem.rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM] != null)
            {
               rewardsList = recipeItem.rewardsModern[QuestConstants.REWARD_GRANT_BUSHEL_ITEM];
               if(rewardsList.length() > 0)
               {
                  itemCode = rewardsList[0].@value;
                  if(itemCode != null && CraftingManager.getInstance().getBushelQuantityInInventory(itemCode) < CraftingConstants.MAX_INDIVIDUAL_UNSHARABLE_BUSHEL_LIMIT)
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      private static function displayUnsharableBushelLimitDialog(recipeItem:RecipeItem = null, bushelItem:FarmItem = null, callback:Function = null) : void
      {
         var bushelItemToDisplay:FarmItem = null;
         var numMostUnsharableBushelInInventory:int = 0;
         var numUnsharableBushelInInventory:int = 0;
         var ingredient:Object = null;
         var item:FarmItem = null;
         var numUnsharableBushels:int = Global.player.craftingState.inventoryState.numUnsharableBushels;
         var numUnsharableBushelsInQueues:int = getNumBushelsOfSubtypeInQueues(CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE);
         if(numUnsharableBushels + numUnsharableBushelsInQueues >= CraftingInventoryStateV2.MAX_UNSHARABLE_BUSHEL_CAPACITY)
         {
            bushelItemToDisplay = Global.player.craftingState.inventoryState.getUnsharableBushelWithLargestQuantity();
         }
         else if(bushelItem != null)
         {
            bushelItemToDisplay = bushelItem;
         }
         else
         {
            numMostUnsharableBushelInInventory = 0;
            numUnsharableBushelInInventory = 0;
            for each(ingredient in recipeItem.ingredients)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
               if(item.type == FarmItemType.BUSHEL && item.subType == CraftingManager.CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE)
               {
                  numUnsharableBushelInInventory = Global.player.craftingState.inventoryState.getNumUnsharableBushelWithCode(ingredient.itemCode);
                  if(numUnsharableBushelInInventory > numMostUnsharableBushelInInventory)
                  {
                     numMostUnsharableBushelInInventory = numUnsharableBushelInInventory;
                     bushelItemToDisplay = item;
                  }
               }
            }
         }
         UI.displayMessage(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_BushelLimit",{
            "item":ZLocUtils.tk_pk(recipeItem.friendlyName),
            "bushel":bushelItemToDisplay.friendlyTitle
         }),GenericPopup.TYPE_OK,callback,"",true);
      }
      
      public static function getCraftLevelFriendlyName(craftLevel:Number) : String
      {
         return "Crafting:CraftingCottages_Status" + craftLevel;
      }
      
      public static function getCraftingStatusCottageNameLocString(craftLevel:int, craftType:String) : String
      {
         var status:String = ZLocUtils.t("Crafting","CraftingCottages_Status" + craftLevel);
         var itemKeySpecific:String = "CraftingStatusCottageName" + craftLevel + "_" + craftType;
         var itemKeyDefault:String = "CraftingStatusCottageName" + craftLevel + "_failoverDefault";
         var failoverEntryArray:Array = new Array();
         failoverEntryArray.push(new ZLocFailoverEntry("Items",itemKeySpecific));
         failoverEntryArray.push(new ZLocFailoverEntry("Items",itemKeyDefault));
         var buildingFriendlyNameKey:String = CraftingManager.getInstance().getCottageFriendlyNameByCraft(craftType);
         var buildingFriendlyName:String = ZLocUtils.tk_pk_asTitle(buildingFriendlyNameKey);
         return ZLocUtils.getFailoverLocString(failoverEntryArray,{
            "building_status":status,
            "building_name":buildingFriendlyName
         });
      }
      
      public static function checkAndShowCottageReminder() : void
      {
         getInstance().setShowPlaceCottageReminderOnLoad();
         getInstance().showCottageReminderOnLoad();
      }
      
      public static function getInstance() : CraftingManager
      {
         if(m_instance == null)
         {
            m_instance = new CraftingManager();
         }
         return m_instance;
      }
      
      public function doPostInit() : void
      {
         if(this.m_showPlaceCottageReminderOnLoad)
         {
            this.showCottageReminderOnLoad();
         }
      }
      
      public function getMasterySignIcon(recipe:RecipeItem, masteryLevel:Number) : String
      {
         var masteryIconUrl:String = "";
         var masterySignItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(recipe.masterySignCode);
         if(masterySignItem)
         {
            masteryIconUrl = masterySignItem.getImageByName("icon_" + masteryLevel);
         }
         return masteryIconUrl;
      }
      
      public function set inTutorialMode(value:Boolean) : void
      {
         this.m_inTutorialMode = value;
      }
      
      public function get inTutorialMode() : Boolean
      {
         return this.m_inTutorialMode;
      }
      
      public function hasPendingMarketReward() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.craftingState.pendingRewards != null && Global.player.craftingState.pendingRewards.length > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function hideAllMarketRewardIndicators() : void
      {
         var objectClass:Class = null;
         var instances:Array = null;
         var i:int = 0;
         var marketStall:MarketStallBuilding = null;
         if(this.hasPendingMarketReward() && !this.m_hasHiddenArrows)
         {
            this.m_hasHiddenArrows = true;
            objectClass = getDefinitionByName("Classes.MarketStallBuilding") as Class;
            if(objectClass != null)
            {
               instances = Global.world.getObjectsByClass(objectClass);
               for(i = 0; i < instances.length; i++)
               {
                  marketStall = instances[i] as MarketStallBuilding;
                  if(marketStall != null)
                  {
                     marketStall.hideArrowDisplay();
                  }
               }
            }
         }
      }
      
      public function showAllMarketRewardIndicators() : void
      {
         var objectClass:Class = null;
         var instances:Array = null;
         var i:int = 0;
         var marketStall:MarketStallBuilding = null;
         if(this.hasPendingMarketReward())
         {
            objectClass = getDefinitionByName("Classes.MarketStallBuilding") as Class;
            if(objectClass != null)
            {
               instances = Global.world.getObjectsByClass(objectClass);
               for(i = 0; i < instances.length; i++)
               {
                  marketStall = instances[i] as MarketStallBuilding;
                  if(marketStall != null)
                  {
                     marketStall.showArrowDisplay();
                  }
               }
            }
         }
      }
      
      public function collectReadyRecipes() : Array
      {
         var instances:Array = null;
         var i:int = 0;
         var craftingCottage:CraftingCottageBuilding = null;
         var readyRecipes:Array = new Array();
         var objectClass:Class = getDefinitionByName("Classes.CraftingCottageBuilding") as Class;
         if(objectClass != null)
         {
            instances = Global.world.getObjectsByClass(objectClass);
            for(i = 0; i < instances.length; i++)
            {
               craftingCottage = instances[i] as CraftingCottageBuilding;
               readyRecipes = readyRecipes.concat(craftingCottage.readyRecipes);
            }
         }
         return readyRecipes;
      }
      
      public function beginForceRewardsFlow(contextStall:MarketStallBuilding) : void
      {
         CraftingStatsManager.recordRewardPageView(true);
         CraftingUI.displayMarketStallWindow(contextStall,true,null);
         this.hideAllMarketRewardIndicators();
         this.hasSeenRewardsPopup = true;
      }
      
      public function getNewBushelBonusAdders(bushelItemCode:String, cropItemCode:String) : int
      {
         var farmItem:SeedItem = null;
         var mastery:Object = null;
         var masteryBonus:int = 0;
         var superCropBonus:int = 0;
         if(this.getCraftTypeofBushel(bushelItemCode) != CraftingManager.BUSHEL_TYPE_SILO)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(cropItemCode) as SeedItem;
            if(Boolean(farmItem) && farmItem.isSuperCrop())
            {
               superCropBonus = Global.farmGameSettingsManager.getInt("bushelSuperCropBonus",3);
            }
            mastery = Global.player.mastery;
            if(Boolean(mastery) && !isNaN(parseInt(mastery[cropItemCode])))
            {
               masteryBonus = mastery[cropItemCode] + 1;
            }
         }
         return masteryBonus + superCropBonus;
      }
      
      public function get hasSeenRewardsPopup() : Boolean
      {
         return this.m_hasSeenRewardsPopup;
      }
      
      public function set hasSeenRewardsPopup(hasSeenRewardsPopup:Boolean) : void
      {
         this.m_hasSeenRewardsPopup = hasSeenRewardsPopup;
      }
      
      private function marketStallBushelFoundDialogs(result:Object, bushelItemCode:String, showImpluseBuy:Boolean) : void
      {
         var marketStallId:int = 0;
         var marketStall:MarketStallBuilding = null;
         var task:CraftingBushelSummaryTask = null;
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
         var hasBushelsAddedToInventory:Boolean = result.hasOwnProperty("bushelsAddedToInventory") && result.bushelsAddedToInventory > 0;
         if(hasBushelsAddedToInventory)
         {
            if(Boolean(result.bushelAddedToStall) && result.marketStallId != null)
            {
               marketStallId = int(result.marketStallId);
               marketStall = Global.world.getObjectById(marketStallId) as MarketStallBuilding;
               if(marketStall != null)
               {
                  marketStall.bushelItemCode = bushelItemCode;
                  marketStall.isConfigured = true;
                  marketStall.serverTimeClosed = result.newTimeExpires;
                  marketStall.reloadImage();
                  this.addToBushelSummaryQueue(bushelItem,marketStall,result.openStallRewardUrl,result.bushelsAddedToInventory);
                  task = new CraftingBushelSummaryTask();
                  task.submit();
               }
            }
            else if(this.hasMaximumNumberOfStallsPlaced())
            {
               if(!this.reconfigurePopupShownForItem(bushelItemCode))
               {
                  this.showReconfigurePopup(bushelItemCode);
               }
            }
            else if(this.getPlacedMarketStalls() > 0 && showImpluseBuy)
            {
               this.showPurchaseAnotherStallPopup();
            }
         }
      }
      
      private function reconfigurePopupShownForItem(bushelItemCode:String) : Boolean
      {
         return this.m_reconfigurePopupsShown[bushelItemCode] == true;
      }
      
      private function firstSiloOrCraftshopBushel(result:Object, bushelItemCode:String) : void
      {
         var firstSeenSiloPopUp:FirstCraftingSiloWindow = null;
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
         var firstCraftingSiloSeenFlag:String = FirstCraftingSiloWindow.getFirstCraftingSiloSeenFlag();
         if(this.getAllCraftingSilosCount() == 0 && (!Global.player.getSeenFlag(firstCraftingSiloSeenFlag) || this.inSiloPlacementRemindExperiment()))
         {
            Global.player.addGift("craftingsilo");
            firstSeenSiloPopUp = new FirstCraftingSiloWindow(bushelItemCode);
            UI.displayPopup(firstSeenSiloPopUp);
         }
         else
         {
            Global.player.setSeenFlag(firstCraftingSiloSeenFlag);
         }
      }
      
      private function inSiloPlacementRemindExperiment() : Boolean
      {
         return true;
      }
      
      private function firstMarketStallDialog(bushelItemCode:String) : void
      {
         var firstSeenPopUp:FirstMarketStallWindow = null;
         var firstMarketStallSeenFlag:String = FirstMarketStallWindow.getFirstMarketStallSeenFlag();
         if(!Global.player.getSeenFlag(firstMarketStallSeenFlag))
         {
            if(this.getAllMarketStallsCount() == 0)
            {
               Global.player.addGift("marketstall");
               firstSeenPopUp = new FirstMarketStallWindow(bushelItemCode);
               UI.displayPopup(firstSeenPopUp);
            }
            else
            {
               Global.player.setSeenFlag(firstMarketStallSeenFlag);
            }
         }
      }
      
      private function handleLabBushelFound(bushelItemCode:String, responseObject:Object, useToaster:Boolean = false) : void
      {
         var bushelItem:FarmItem = null;
         var harvestSource:FarmItem = null;
         var buildingName:String = null;
         var dialogBundle:String = null;
         var localizedCopy:String = null;
         var callbackClosure:Function = null;
         var popUp:GenericIconPopup = null;
         if(responseObject.hasOwnProperty("labRewardUrl") && responseObject.hasOwnProperty("bushelsAddedToInventory"))
         {
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
            if(responseObject["src"] != null)
            {
               harvestSource = Global.farmGameSettingsManager.getFarmItemByName(responseObject.src);
            }
            else
            {
               harvestSource = Global.farmGameSettingsManager.getFarmItemByCode(bushelItem.crop);
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               buildingName = harvestSource.getStringFromDataSource("buildingName");
            }
            else
            {
               buildingName = harvestSource.xml.@buildingName;
            }
            dialogBundle = buildingName + "BushelFound";
            localizedCopy = ZLocUtils.t("Dialogs",dialogBundle,{
               "bushel":ZLocUtils.tk_pk(bushelItem.friendlyName),
               "source":ZLocUtils.tk_pk_asTitle(harvestSource.friendlyName)
            });
            callbackClosure = function(evt:GenericPopupEvent):void
            {
               var buildingName:String = null;
               if(evt.button == GenericPopup.ACCEPT)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     buildingName = harvestSource.getStringFromDataSource("buildingName");
                  }
                  else
                  {
                     buildingName = harvestSource.xml.@buildingName;
                  }
                  CraftingManager.getInstance().displayShareMarketStallFeed(bushelItem,responseObject.bushelsAddedToInventory,responseObject.labRewardUrl,buildingName + "_shareharvestbushel");
               }
            };
            if(useToaster)
            {
               UI.handlePopupDisplayForRetention(localizedCopy,GenericPopup.TYPE_SHARE,callbackClosure,bushelItem.icon,"",{"dontCloseToaster":true},true);
            }
            else
            {
               popUp = new GenericIconPopup(localizedCopy,GenericPopup.TYPE_SHARE,callbackClosure,bushelItem.icon);
               Global.popupManager.addInactiveUserPopup(popUp);
            }
         }
      }
      
      public function recordBushelFound(responseObject:Object, useToater:Boolean = false, organic:Boolean = false, setLastBushelFound:Boolean = true) : void
      {
         var result:Object = null;
         var amountToShare:Number = NaN;
         var beginOOS_itemsStr:String = null;
         var marketStall:MarketStallBuilding = null;
         result = responseObject.foundBushel;
         var bushelItemCode:String = result.bushelCode;
         renderBushelFoundStatus(bushelItemCode);
         var bushelCraftType:int = this.getCraftTypeofBushel(bushelItemCode);
         switch(bushelCraftType)
         {
            case CraftingManager.BUSHEL_TYPE_SILO:
               amountToShare = parseInt(result.bushelsAddedToInventory) + parseInt(result.bushelsAddedToSharedReward);
               this.harvestedCraftingSiloBushel(result.craftingSiloId,result.openSiloRewardUrl,bushelItemCode,amountToShare);
               break;
            case CraftingManager.BUSHEL_TYPE_LAB:
               this.handleLabBushelFound(bushelItemCode,result,useToater);
               break;
            case CraftingManager.BUSHEL_TYPE_UNSHARABLE:
            case CraftingManager.BUSHEL_TYPE_VILLAGE:
               break;
            default:
               this.marketStallBushelFoundDialogs(result,bushelItemCode,setLastBushelFound);
         }
         if(result.bushelsAddedToInventory > 0)
         {
            this.addItemToInventory(bushelItemCode,result.bushelsAddedToInventory);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
            {
               beginOOS_itemsStr = "item_" + bushelItemCode + ":" + result.bushelsAddedToInventory;
               FarmStatsManager.count("beginOOS","client","add_recordBushelFound",beginOOS_itemsStr);
            }
         }
         if(result.bushelsAddedToInventory > 0 || result.bushelsAddedToSharedReward > 0)
         {
            if(bushelCraftType == CraftingManager.BUSHEL_TYPE_SILO)
            {
               this.firstSiloOrCraftshopBushel(result,bushelItemCode);
            }
            else if(bushelCraftType == CraftingManager.BUSHEL_TYPE_STALL)
            {
               this.firstMarketStallDialog(bushelItemCode);
            }
         }
         if(result.bushelsAddedToSharedReward > 0 && bushelCraftType == CraftingManager.BUSHEL_TYPE_STALL)
         {
            marketStall = Global.player.craftingState.getMarketStall();
            if(Boolean(marketStall) && Boolean(marketStall.readyToExpand()) && this.canShowExpandDialog())
            {
               this.showStallExpandDialog(marketStall);
            }
            else if(this.canShowExpandDialog())
            {
               this.markSeenExpandDialog();
               UI.displayMessage(ZLocUtils.t("Crafting","BushelBundleBuyNoRoom"),0,this.m_closePurchaseDialogCallback,"",true);
            }
         }
         if(this.getPlacedMarketStalls() > 0)
         {
            CraftingStatsManager.recordFoundBushel();
         }
      }
      
      public function canShowExpandDialog() : Boolean
      {
         var indicatorLastShown:Number = Global.player.getFeatureLastShown(this.MARKET_STALL_EXPAND_SHOWN);
         return indicatorLastShown + FarmGameUtil.NUM_SECS_IN_DAY < GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public function markSeenExpandDialog() : void
      {
         Global.player.setFeatureLastShown(this.MARKET_STALL_EXPAND_SHOWN,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
      }
      
      private function showStallExpandDialog(marketStall:MarketStallBuilding, closeDialogCallback:Function = null) : void
      {
         var localizedCopy:String = null;
         var config:GenericDialogConfig = null;
         if(this.m_expansionDialog == null)
         {
            this.markSeenExpandDialog();
            FarmStatsManager.count("dialog","marketstall_full_expand","view");
            localizedCopy = ZLocUtils.t("Crafting","BushelInventoryFullDialog_ExpandText");
            config = new GenericDialogConfig();
            config.setBodyText(localizedCopy);
            config.showCloseButton(false);
            config.setImageUrl(marketStall.getItem().icon);
            config.addButton(ZLocUtils.t("Dialogs","Okay"),GenericDialogConfig.COLOR_BLUE,ZCacheUtil.applyPartial(this.onMarketStallOkayCallback,this,[marketStall]));
            config.addButton(ZLocUtils.t("Dialogs","CompleteNowCamel"),GenericDialogConfig.COLOR_GREEN,ZCacheUtil.applyPartial(this.onMarketStallExpandCallback,this,[marketStall]));
            config.setName("marketstall_full_expand");
            this.m_expansionDialog = GenericDialog.createFromConfig(config);
            this.m_expansionDialogCallback = closeDialogCallback;
            if(this.m_expansionDialog)
            {
               this.m_expansionDialog.show();
            }
         }
      }
      
      private function showStallFullDialog(bushelsFound:int, bushelItemCode:String) : void
      {
         var localizedCopy:String = null;
         CraftingStatsManager.recordInventoryFullPopupPageView();
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
         if(bushelsFound > 1)
         {
            localizedCopy = ZLocUtils.t("Crafting","BushelInventoryFullDialog_MainTextPlural",{
               "quantity":bushelsFound,
               "item":ZLocUtils.tk_pk(bushelItem.friendlyName,"",bushelsFound)
            });
         }
         else
         {
            localizedCopy = ZLocUtils.t("Crafting","BushelInventoryFullDialog_MainTextSingular",{"item":ZLocUtils.tk_pk(bushelItem.friendlyName)});
         }
         var popUp:GenericPopup = new GenericPopup(localizedCopy,GenericPopup.TYPE_SHARECANCEL,this.onBushelInventoryFullClick);
         Global.popupManager.addInactiveUserPopup(popUp);
      }
      
      protected function showSiloBushelShareDialog(summary:BushelsFoundSummary, siloFull:Boolean) : void
      {
         var dialogBundle:String = null;
         var dialogType:int = 0;
         var popUp:GenericIconPopup = null;
         if(siloFull)
         {
            dialogBundle = "CraftingSiloBushelFound_silo_full";
         }
         else
         {
            dialogBundle = "CraftingSiloBushelFound_silo_not_full";
         }
         var bushelItem:FarmItem = summary.bushelItem;
         var harvestSource:FarmItem = summary.cropItem;
         var bushelsFound:int = summary.quantity;
         var localizedCopy:String = ZLocUtils.t("Dialogs",dialogBundle,{
            "item":ZLocUtils.tk_pk(harvestSource.friendlyName),
            "quantity":bushelsFound,
            "item_same":ZLocUtils.tk_pk(bushelItem.friendlyName,"",bushelsFound)
         });
         if(Global.flashHotParams["FE_FREE_BUSHEL_EXPLOIT_FIX_TEMPRT"])
         {
            dialogType = GenericPopup.TYPE_OK;
         }
         else
         {
            dialogType = GenericPopup.TYPE_SHARE;
         }
         if(!siloFull && UI.shouldBlockPopupForRetention())
         {
            UI.handlePopupDisplayForRetention(localizedCopy,dialogType,this.onSiloBushelDialogClick,bushelItem.icon,null);
         }
         else
         {
            popUp = new GenericIconPopup(localizedCopy,dialogType,this.onSiloBushelDialogClick,bushelItem.icon);
            Global.popupManager.addInactiveUserPopup(popUp);
         }
      }
      
      private function onSiloBushelDialogClick(e:GenericPopupEvent) : void
      {
         var summary:BushelsFoundSummary = this.m_siloBushelDialogSummaryQueue.pop();
         if(!Global.flashHotParams["FE_FREE_BUSHEL_EXPLOIT_FIX_TEMPRT"])
         {
            if(e.button == GenericPopup.ACCEPT)
            {
               this.shareBushel(summary.bushelItem.code,summary.quantity,this.FEED_BUNDLE_ID_SHARE_HARVEST_BUSHEL,false,summary.rewardUrl);
            }
         }
         this.conditionalLaunchSiloBushelSummaryDialog();
      }
      
      private function onMarketStallExpandCallback(stallToExpand:MarketStallBuilding, isAccept:Boolean) : void
      {
         if(isAccept && !stallToExpand.hasReachedMaxExpansionLevel())
         {
            FarmStatsManager.count("dialog","marketstall_full_expand","complete",stallToExpand.getExpandCashNeeded().toString());
            stallToExpand.beginCompleteExpansionFlow(0,this.m_expansionDialogCallback,this.m_expansionDialogCallback);
         }
         this.m_expansionDialog.destroy();
         this.m_expansionDialog = null;
         this.m_expansionDialogCallback = null;
         this.conditionalLaunchSiloBushelSummaryDialog();
      }
      
      private function onSiloBushelExpandCallback(siloToExpand:FeatureBuilding, isAccept:Boolean) : void
      {
         var summary:BushelsFoundSummary = this.m_siloBushelDialogSummaryQueue.pop();
         if(isAccept && !siloToExpand.hasReachedMaxExpansionLevel())
         {
            FarmStatsManager.count("dialog","craftsilo_full_expand","expand",siloToExpand.getCashNeeded().toString());
            siloToExpand.beginCompleteExpansionFlow();
         }
         this.m_expansionDialog.destroy();
         this.m_expansionDialog = null;
         this.conditionalLaunchSiloBushelSummaryDialog();
      }
      
      public function getRecipeDataForSpecializationAndType(craftType:String, specializationId:String, recipeType:String, searchString:String = "", sortOption:Object = null) : Array
      {
         var sortBy:String = null;
         var sortDirection:String = null;
         var allRecipes:Array = new Array();
         var result:Array = new Array();
         var searchStringRecipes:Array = new Array();
         var recipeTypesHash:Dictionary = Global.craftConfigSettings.getRecipeTypesHash();
         if(Boolean(recipeTypesHash.hasOwnProperty(craftType)) && Boolean(recipeTypesHash[craftType].hasOwnProperty(specializationId)) && Boolean(recipeTypesHash[craftType][specializationId].hasOwnProperty(recipeType)))
         {
            allRecipes = recipeTypesHash[craftType][specializationId][recipeType];
         }
         var eligibleRecipes:Array = this.getEligibleRecipes(craftType,allRecipes);
         if(searchString != "")
         {
            searchStringRecipes = this.filterRecipesBySearchString(craftType,searchString,eligibleRecipes);
         }
         else
         {
            searchStringRecipes = eligibleRecipes;
         }
         if(sortOption)
         {
            sortBy = sortOption.sortBy;
            sortDirection = sortOption.direction;
            result = sortRecipesBy(searchStringRecipes,sortBy,sortDirection);
         }
         return result;
      }
      
      private function filterRecipesBySearchString(craftingSkillKey:String, searchString:String, eligibleRecipes:Array) : Array
      {
         var craftshopRecipe:Object = null;
         var currentRecipeId:String = null;
         var recipeName:String = null;
         if(this.m_lastFilterSearchStringObject[craftingSkillKey] != searchString)
         {
            this.m_filteredRecipeIds[craftingSkillKey] = new Array();
            for each(craftshopRecipe in eligibleRecipes)
            {
               currentRecipeId = craftshopRecipe.recipeId;
               recipeName = this.m_craftshopRecipeNames[craftingSkillKey][currentRecipeId];
               recipeName = recipeName.toLowerCase();
               if(recipeName.indexOf(searchString) != -1)
               {
                  this.m_filteredRecipeIds[craftingSkillKey].push({"recipeId":currentRecipeId});
               }
            }
         }
         var filteredRecipeData:Array = this.m_filteredRecipeIds[craftingSkillKey];
         this.m_lastFilterSearchStringObject[craftingSkillKey] = searchString;
         return filteredRecipeData;
      }
      
      private function getEligibleRecipes(craftingSkillKey:String, recipeData:Array) : Array
      {
         var configRecipe:Object = null;
         var configRecipeId:String = null;
         var recipeItem:RecipeItem = null;
         var trimmedRecipeData:Array = new Array();
         for each(configRecipe in recipeData)
         {
            configRecipeId = configRecipe.recipeId;
            recipeItem = Global.craftConfigSettings.getRecipeById(configRecipeId);
            if(isRecipeValid(recipeItem))
            {
               trimmedRecipeData.push(configRecipe);
               if(this.m_craftshopRecipeNames[craftingSkillKey] == null)
               {
                  this.m_craftshopRecipeNames[craftingSkillKey] = new Object();
               }
               this.cacheRecipeNames(craftingSkillKey,configRecipeId,recipeItem.friendlyTitle);
            }
         }
         return trimmedRecipeData;
      }
      
      private function cacheRecipeNames(craftingSkillKey:String, recipeId:String, recipeName:String) : void
      {
         if(this.m_craftshopRecipeNames[craftingSkillKey][recipeId])
         {
            this.m_craftshopRecipeNames[craftingSkillKey][recipeId] = recipeName;
         }
      }
      
      public function getRecipeData(craftingSkillKey:String, specialization:String, filterBySearchString:Boolean = true, showExpired:Boolean = false, searchString:String = "") : Array
      {
         var configData:Array = null;
         var configRecipeId:String = null;
         var recipeItem:RecipeItem = null;
         var recipieIdObject:Object = null;
         if(this.m_craftshopRecipeIds[craftingSkillKey] == null)
         {
            this.m_craftshopRecipeIds[craftingSkillKey] = new Array();
            this.m_craftshopValidRecipesIds[craftingSkillKey] = new Array();
            this.m_craftshopRecipeNames[craftingSkillKey] = new Object();
            configData = Global.craftConfigSettings.getRecipeIdsForSpecialization(craftingSkillKey,specialization);
            for each(configRecipeId in configData)
            {
               recipeItem = Global.craftConfigSettings.getRecipeById(configRecipeId);
               recipieIdObject = {"recipeId":configRecipeId};
               if(isRecipeValid(recipeItem))
               {
                  this.m_craftshopValidRecipesIds[craftingSkillKey].push(recipieIdObject);
               }
               this.m_craftshopRecipeIds[craftingSkillKey].push(recipieIdObject);
               this.m_craftshopRecipeNames[craftingSkillKey][configRecipeId] = ZLocUtils.tk_pk_asTitle(recipeItem.friendlyName);
            }
         }
         var craftShopRecipies:Array = showExpired ? this.m_craftshopRecipeIds[craftingSkillKey] : this.m_craftshopValidRecipesIds[craftingSkillKey];
         var resultRecipeIds:Array = new Array();
         if(filterBySearchString && searchString != "")
         {
            resultRecipeIds = this.filterRecipesBySearchString(craftingSkillKey,searchString,craftShopRecipies);
         }
         else
         {
            resultRecipeIds = craftShopRecipies;
         }
         return resultRecipeIds;
      }
      
      private function onMarketStallOkayCallback(marketStall:MarketStallBuilding, isAccept:Boolean) : void
      {
         if(isAccept)
         {
            marketStall.displayStorageDialog(MarketStallBuilding.SHOW_EXPAND_TAB);
         }
         FarmStatsManager.count("dialog","marketstall_full_expand","ok");
         this.m_expansionDialog.destroy();
         this.m_expansionDialog = null;
         if(this.m_expansionDialogCallback != null)
         {
            this.m_expansionDialogCallback();
            this.m_expansionDialogCallback = null;
         }
         this.conditionalLaunchSiloBushelSummaryDialog();
      }
      
      private function onOkayCallback(siloToExpand:FeatureBuilding, isAccept:Boolean) : void
      {
         var summary:BushelsFoundSummary = this.m_siloBushelDialogSummaryQueue.pop();
         if(isAccept)
         {
            FarmStatsManager.count("dialog","craftsilo_full_expand","ask");
            siloToExpand.displayExpandDialog();
         }
         this.m_expansionDialog.destroy();
         this.m_expansionDialog = null;
         this.conditionalLaunchSiloBushelSummaryDialog();
      }
      
      protected function conditionalLaunchSiloBushelSummaryDialog() : void
      {
         var summary:BushelsFoundSummary = null;
         var maxCapacity:Number = NaN;
         var currentCapacity:Number = NaN;
         var showShareDialog:Boolean = false;
         var craftSilos:Array = null;
         var silo:FeatureBuilding = null;
         if(this.m_siloBushelDialogSummaryQueue.length > 0)
         {
            summary = this.m_siloBushelDialogSummaryQueue[this.m_siloBushelDialogSummaryQueue.length - 1];
            maxCapacity = Global.player.craftingState.inventoryState.craftingSiloMaxCapacity;
            currentCapacity = Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity;
            showShareDialog = true;
            if(currentCapacity >= maxCapacity)
            {
               craftSilos = this.getCraftingSilosInWorld();
               for each(silo in craftSilos)
               {
                  if(!silo.hasReachedMaxExpansionLevel())
                  {
                     this.showExpandDialog(silo);
                     showShareDialog = false;
                     break;
                  }
               }
               if(showShareDialog)
               {
                  this.showSiloBushelShareDialog(summary,true);
               }
            }
            else
            {
               this.showSiloBushelShareDialog(summary,false);
            }
         }
      }
      
      protected function showExpandDialog(silo:FeatureBuilding) : void
      {
         var localizedCopy:String = null;
         var config:GenericDialogConfig = null;
         if(this.m_expansionDialog == null)
         {
            localizedCopy = ZLocUtils.t("Dialogs","CraftingSiloBushelFound_expand",{"quantity":(silo.getNextExpansionCapacity() - silo.capacity).toString()});
            FarmStatsManager.count("dialog","craftsilo_full_expand","view");
            config = new GenericDialogConfig();
            config.setBodyText(localizedCopy);
            config.setImageUrl(silo.getFarmItem().getImageByName("icon_" + (silo.storageLevel - 1).toString()));
            config.showCloseButton(true);
            config.addButton(ZLocUtils.t("Dialogs","Okay"),GenericDialogConfig.COLOR_BLUE,ZCacheUtil.applyPartial(this.onOkayCallback,this,[silo]));
            config.addButton(ZLocUtils.t("Dialogs","CompleteNowCamel"),GenericDialogConfig.COLOR_GREEN,ZCacheUtil.applyPartial(this.onSiloBushelExpandCallback,this,[silo]));
            config.setName("craftsilo_full_expand");
            this.m_expansionDialog = GenericDialog.createFromConfig(config);
            if(this.m_expansionDialog)
            {
               this.m_expansionDialog.show();
            }
         }
      }
      
      public function handleMastery(goals:Array) : void
      {
         var idx:int = 0;
         var goal:Object = null;
         var recipe:RecipeItem = null;
         var masterySignName:String = null;
         var objs:Array = null;
         if(goals.length > 0)
         {
            for(idx = 0; idx < goals.length; idx++)
            {
               goal = goals[idx];
               recipe = Global.craftConfigSettings.getRecipeByProductItemCode(goal.code);
               masterySignName = Global.farmGameSettingsManager.getFarmItemByCode(recipe.masterySignCode).name;
               objs = Global.world.getObjectsByNames([masterySignName]);
               if(Boolean(objs) && objs.length > 0)
               {
                  (objs[0] as RecipeMasterySign).level = goal.level;
               }
               else if(!(Global.player.getGiftCountForItem(masterySignName) > 0 || Global.player.getInventoryItemQuantity(recipe.masterySignCode) > 0))
               {
                  if(Global.player.masterySignEnabled())
                  {
                     Global.player.addGift(masterySignName);
                  }
               }
            }
            if(!Global.player.getSeenFlag("CMIntro"))
            {
               Global.player.setSeenFlag("CMIntro");
               if(Global.player.masterySignEnabled())
               {
                  this.showFirstTimeMasteryPopup(goals);
               }
               else
               {
                  this.showMasteryPopup(goals);
               }
            }
            else
            {
               this.showMasteryPopup(goals);
            }
         }
      }
      
      private function showFirstTimeMasteryPopup(goals:Array) : void
      {
         Global.popupManager.addInactiveUserPopup(new RecipeMasteryOnBoard(goals));
      }
      
      private function showMasteryPopup(result:Array) : void
      {
         Global.popupManager.addInactiveUserPopup(new RecipeMasteryWindow(result));
      }
      
      public function getRecipeMasteryEarnedForCraftType(craftType:String) : int
      {
         var recipe:RecipeItem = null;
         var result:int = 0;
         var skillState:CraftingSkillState = Global.player.craftingState.craftingSkillState;
         var recipeIds:Array = Global.craftConfigSettings.getAllRecipeIds(craftType);
         var recipeId:String = "";
         var recipeState:RecipeState = null;
         for(var recipeIdIndex:int = 0; recipeIdIndex < recipeIds.length; recipeIdIndex++)
         {
            recipeId = recipeIds[recipeIdIndex];
            recipe = Global.craftConfigSettings.getRecipeById(recipeId);
            if(recipe != null && recipe.sharedMastery != "")
            {
               if(recipeIds.indexOf(recipe.sharedMastery) != -1)
               {
                  continue;
               }
            }
            recipeState = skillState.getRecipeStateById(recipeId);
            result += recipeState.getCompletedLevel();
         }
         return result;
      }
      
      public function get reconfigureOnPlace() : Boolean
      {
         return this.m_reconfigureOnPlace;
      }
      
      public function set reconfigureOnPlace(newReconfigureOnPlace:Boolean) : void
      {
         this.m_reconfigureOnPlace = newReconfigureOnPlace;
      }
      
      public function get lastBushelFound() : String
      {
         return this.m_lastBushelFound;
      }
      
      private function onBushelInventoryFullClick(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            CraftingStatsManager.recordInventoryFullPopupShare();
            CraftingFeed.fullBushelFeed(this.m_sharedFullRewardUrl,this.m_sharedFullFeedBushelCode);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_sharedFullRewardUrl]));
         }
      }
      
      private function showReconfigurePopup(bushel:String) : void
      {
         var popUp:GenericPopup = new ReconfigureStallWindow(bushel);
         UI.displayPopup(popUp);
         this.m_reconfigurePopupsShown[bushel] = true;
      }
      
      private function showPurchaseAnotherStallPopup() : void
      {
         var task:CraftingImpulseBuyTask = null;
         if(!this.m_hasSeenImpulseBuyPopup)
         {
            this.m_hasSeenImpulseBuyPopup = true;
            task = new CraftingImpulseBuyTask();
            task.submit();
         }
      }
      
      public function addItemToInventory(itemCode:String, quantity:int) : void
      {
         var thisItem:MarketInventoryItem = null;
         var currentQty:int = 0;
         var newItem:MarketInventoryItem = null;
         var bushelType:int = this.getCraftTypeofBushel(itemCode);
         var items:Dictionary = Global.player.craftingState.inventoryState.marketStallItems;
         if(bushelType == BUSHEL_TYPE_SILO)
         {
            items = Global.player.craftingState.inventoryState.craftingSiloItems;
         }
         else if(bushelType == BUSHEL_TYPE_LAB)
         {
            items = Global.player.craftingState.inventoryState.labItems;
         }
         else if(bushelType == BUSHEL_TYPE_UNSHARABLE)
         {
            items = Global.player.craftingState.inventoryState.unsharableItems;
         }
         else if(bushelType == BUSHEL_TYPE_VILLAGE)
         {
            items = Global.player.craftingState.inventoryState.villageStorageItems;
         }
         var existingItemFound:Boolean = false;
         for each(thisItem in items)
         {
            if(thisItem.itemCode == itemCode)
            {
               thisItem.quantity += quantity;
               existingItemFound = true;
               break;
            }
         }
         if(bushelType == BUSHEL_TYPE_STALL)
         {
            currentQty = 0;
            if(existingItemFound)
            {
               currentQty = thisItem.quantity;
            }
            else
            {
               currentQty = quantity;
            }
            FarmStatsManager.count("marketstall","add_bushel",quantity.toString(),currentQty.toString(),Global.player.craftingState.inventoryState.maxCapacity.toString());
         }
         if(!existingItemFound)
         {
            newItem = new MarketInventoryItem();
            newItem.quantity = quantity;
            newItem.itemCode = itemCode;
            if(bushelType == BUSHEL_TYPE_SILO)
            {
               Global.player.craftingState.inventoryState.craftingSiloItems[itemCode] = newItem;
            }
            else if(bushelType == BUSHEL_TYPE_STALL)
            {
               Global.player.craftingState.inventoryState.marketStallItems[itemCode] = newItem;
            }
            else if(bushelType == BUSHEL_TYPE_LAB)
            {
               Global.player.craftingState.inventoryState.labItems[itemCode] = newItem;
            }
            else if(bushelType == BUSHEL_TYPE_UNSHARABLE)
            {
               Global.player.craftingState.inventoryState.unsharableItems[itemCode] = newItem;
            }
            else if(bushelType == BUSHEL_TYPE_VILLAGE)
            {
               Global.player.craftingState.inventoryState.villageStorageItems[itemCode] = newItem;
            }
         }
      }
      
      public function getCraftTypeofBushel(itemCode:String) : int
      {
         var bushelType:int = CraftingManager.BUSHEL_TYPE_STALL;
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(bushelItem != null)
         {
            if(bushelItem.subType == CRAFTING_BUSHEL_SUBTYPE_SILO_ANIMAL || bushelItem.subType == CRAFTING_BUSHEL_SUBTYPE_SILO_TREE)
            {
               bushelType = BUSHEL_TYPE_SILO;
            }
            else if(bushelItem.subType == CRAFTING_BUSHEL_SUBTYPE_LAB)
            {
               bushelType = BUSHEL_TYPE_LAB;
            }
            else if(bushelItem.subType == CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE)
            {
               bushelType = BUSHEL_TYPE_UNSHARABLE;
            }
            else if(bushelItem.subType == CRAFTING_BUSHEL_SUBTYPE_VILLAGE)
            {
               bushelType = BUSHEL_TYPE_VILLAGE;
            }
         }
         return bushelType;
      }
      
      public function getBushelQuantityInInventory(itemCode:String, ignoreDirtyFlag:Boolean = false) : int
      {
         var count:int = 0;
         if(Global.player.craftingState.inventoryState.marketStallItems[itemCode])
         {
            count += (Global.player.craftingState.inventoryState.marketStallItems[itemCode] as MarketInventoryItem).quantity;
         }
         if(Global.player.craftingState.inventoryState.craftingSiloItems[itemCode])
         {
            count += (Global.player.craftingState.inventoryState.craftingSiloItems[itemCode] as MarketInventoryItem).quantity;
         }
         if(Global.player.craftingState.inventoryState.labItems[itemCode])
         {
            count += (Global.player.craftingState.inventoryState.labItems[itemCode] as MarketInventoryItem).quantity;
         }
         if(Global.player.craftingState.inventoryState.unsharableItems[itemCode])
         {
            count += (Global.player.craftingState.inventoryState.unsharableItems[itemCode] as MarketInventoryItem).quantity;
         }
         if(Global.player.craftingState.inventoryState.villageStorageItems[itemCode])
         {
            count += (Global.player.craftingState.inventoryState.villageStorageItems[itemCode] as MarketInventoryItem).quantity;
         }
         return count;
      }
      
      public function getDefaultExchangeBushel() : FarmItem
      {
         var cottage:CraftingCottageBuilding = null;
         var reward:Object = null;
         var defaultBushel:FarmItem = null;
         var placedCottages:Array = this.getPlacedCraftingCottages();
         var minBushels:Number = -1;
         for each(cottage in placedCottages)
         {
            if(cottage.count < minBushels || minBushels < 0)
            {
               reward = Global.craftConfigSettings.getDefaultReward(cottage.craftType,"gold");
               defaultBushel = Global.farmGameSettingsManager.getFarmItemByName(reward.item);
               minBushels = cottage.count;
            }
         }
         return defaultBushel;
      }
      
      public function reconfigureMarketStall(marketStallId:int, newBushelCode:String) : void
      {
         var transaction:TReconfigureMarketStall = null;
         var marketStall:MarketStallBuilding = Global.world.getObjectById(marketStallId) as MarketStallBuilding;
         if(marketStall != null)
         {
            marketStall.bushelItemCode = newBushelCode;
            marketStall.isConfigured = true;
            marketStall.serverTimeClosed = this.getEstimatedStallClosureTime(newBushelCode);
            marketStall.reloadImage();
            transaction = new TReconfigureMarketStall(marketStallId,newBushelCode);
            TransactionManager.addTransaction(transaction,true);
         }
      }
      
      public function reconfigureMarketStallInitial(marketStall:MarketStallBuilding, newBushelCode:String) : void
      {
         var transaction:TReconfigureMarketStall = null;
         if(marketStall != null)
         {
            marketStall.bushelItemCode = newBushelCode;
            marketStall.isConfigured = true;
            marketStall.serverTimeClosed = this.getEstimatedStallClosureTime(newBushelCode);
            marketStall.reloadImage();
            transaction = new TReconfigureMarketStall(-1,newBushelCode);
            TransactionManager.addTransaction(transaction,true);
         }
      }
      
      private function getEstimatedStallClosureTime(bushelCode:String) : Number
      {
         var bushelCrop:String = null;
         var bushelXml:XML = null;
         var stallDuration:Number = CraftingConstants.BASE_STALL_DURATION;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            bushelCrop = Global.farmGameSettingsManager.getFarmItemByCode(bushelCode).crop;
         }
         else
         {
            bushelXml = Global.farmGameSettingsManager.getItemXMLByCode(bushelCode);
            bushelCrop = bushelXml.crop;
         }
         var cropMastery:Mastery = Global.farmGameSettingsManager.getMasteryByCode(bushelCrop);
         if(cropMastery != null)
         {
            stallDuration += Math.floor((cropMastery.currentLevel + 1) * CraftingConstants.STALL_MASTERY_MODIFER);
         }
         return Math.floor(GlobalEngine.serverTime / 1000) + stallDuration;
      }
      
      public function deductItemFromCraftingInventory(itemCode:String, quantity:int = 1) : Boolean
      {
         var thisItem:MarketInventoryItem = null;
         var remainingQuantity:int = quantity;
         var items:Dictionary = new Dictionary();
         switch(this.getCraftTypeofBushel(itemCode))
         {
            case CraftingManager.BUSHEL_TYPE_SILO:
               items = Global.player.craftingState.inventoryState.craftingSiloItems;
               break;
            case CraftingManager.BUSHEL_TYPE_STALL:
               items = Global.player.craftingState.inventoryState.marketStallItems;
               break;
            case CraftingManager.BUSHEL_TYPE_LAB:
               items = Global.player.craftingState.inventoryState.labItems;
               break;
            case CraftingManager.BUSHEL_TYPE_UNSHARABLE:
               items = Global.player.craftingState.inventoryState.unsharableItems;
               break;
            case CraftingManager.BUSHEL_TYPE_VILLAGE:
               items = Global.player.craftingState.inventoryState.villageStorageItems;
         }
         for each(thisItem in items)
         {
            if(thisItem.itemCode == itemCode && thisItem.quantity > 0)
            {
               if(remainingQuantity <= thisItem.quantity)
               {
                  thisItem.quantity -= remainingQuantity;
                  remainingQuantity = 0;
               }
               else
               {
                  remainingQuantity -= thisItem.quantity;
                  thisItem.quantity = 0;
               }
               if(this.getCraftTypeofBushel(itemCode) == BUSHEL_TYPE_STALL)
               {
                  FarmStatsManager.count("marketstall","remove_bushel",quantity.toString(),thisItem.quantity.toString(),Global.player.craftingState.inventoryState.maxCapacity.toString());
               }
            }
            if(remainingQuantity == 0)
            {
               break;
            }
         }
         switch(this.getCraftTypeofBushel(itemCode))
         {
            case CraftingManager.BUSHEL_TYPE_SILO:
               Global.player.craftingState.inventoryState.craftingSiloItems = this.pruneCraftingInventory(Global.player.craftingState.inventoryState.craftingSiloItems);
               break;
            case CraftingManager.BUSHEL_TYPE_STALL:
               Global.player.craftingState.inventoryState.marketStallItems = this.pruneCraftingInventory(Global.player.craftingState.inventoryState.marketStallItems);
               break;
            case CraftingManager.BUSHEL_TYPE_LAB:
               Global.player.craftingState.inventoryState.labItems = this.pruneCraftingInventory(Global.player.craftingState.inventoryState.labItems);
               break;
            case CraftingManager.BUSHEL_TYPE_UNSHARABLE:
               Global.player.craftingState.inventoryState.unsharableItems = this.pruneCraftingInventory(Global.player.craftingState.inventoryState.unsharableItems);
               break;
            case CraftingManager.BUSHEL_TYPE_VILLAGE:
               Global.player.craftingState.inventoryState.villageStorageItems = this.pruneCraftingInventory(Global.player.craftingState.inventoryState.villageStorageItems);
         }
         return remainingQuantity == 0;
      }
      
      public function pruneCraftingInventory(existing:Dictionary) : Dictionary
      {
         var thisItem:MarketInventoryItem = null;
         var newInventory:Dictionary = new Dictionary();
         for each(thisItem in existing)
         {
            if(thisItem.quantity > 0)
            {
               newInventory[thisItem.itemCode] = thisItem;
            }
         }
         return newInventory;
      }
      
      public function beginPurchaseRecipeBundle(recipeItem:RecipeItem, closePurchaseDialogCallback:Function, purchaseDialogCallback:Function = null) : void
      {
         var dialog:PurchaseBushelBundles = null;
         var numberOfSiloItemsRequired:int = 0;
         var remainingSiloCapacity:int = 0;
         var marketStall:MarketStallBuilding = null;
         this.m_closePurchaseDialogCallback = closePurchaseDialogCallback;
         this.m_purchaseDialogCallback = purchaseDialogCallback;
         var numSafePurchases:int = this.getNumberOfSafePurchases(recipeItem);
         if(numSafePurchases > 0)
         {
            dialog = new PurchaseBushelBundles(recipeItem,this.onPurchaseBundle,numSafePurchases);
            UI.displayPopup(dialog,false);
         }
         else if(numSafePurchases == NO_UNSHARABLE_INVENTORY_ROOM)
         {
            displayUnsharableBushelLimitDialog(recipeItem,null,this.m_closePurchaseDialogCallback);
         }
         else
         {
            numberOfSiloItemsRequired = this.getNumberOfBushelsOfTypeInRecipe(recipeItem,BUSHEL_TYPE_SILO);
            if(numberOfSiloItemsRequired > 0)
            {
               remainingSiloCapacity = Global.player.craftingState.inventoryState.craftingSiloMaxCapacity - Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity;
               if(remainingSiloCapacity < 0)
               {
                  remainingSiloCapacity = 0;
               }
               if(Global.player.craftingState.inventoryState.craftingSiloMaxCapacity == 0)
               {
                  UI.displayMessage(ZLocUtils.t("Crafting","BushelBundleBuyNoCraftingSilo"),0,this.m_closePurchaseDialogCallback,"",true);
               }
               else if(numberOfSiloItemsRequired > remainingSiloCapacity)
               {
                  UI.displayMessage(ZLocUtils.t("Crafting","BushelBundleBuyNoRoomInCraftingSilo"),0,this.m_closePurchaseDialogCallback,"",true);
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Crafting","BushelBundleBuyNoRoom"),0,this.m_closePurchaseDialogCallback,"",true);
               }
            }
            else
            {
               marketStall = Global.player.craftingState.getMarketStall();
               if(Boolean(marketStall) && Boolean(marketStall.readyToExpand()) && this.canShowExpandDialog())
               {
                  this.showStallExpandDialog(marketStall,closePurchaseDialogCallback);
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Crafting","BushelBundleBuyNoRoom"),0,this.m_closePurchaseDialogCallback,"",true);
               }
            }
         }
      }
      
      protected function getNumberOfBushelsOfTypeInRecipe(recipeItem:RecipeItem, bushelType:int) : int
      {
         var ingredient:Object = null;
         var total:int = 0;
         if(recipeItem != null)
         {
            for each(ingredient in recipeItem.ingredients)
            {
               if(this.getCraftTypeofBushel(ingredient.itemCode) == bushelType)
               {
                  total += ingredient.quantityRequired;
               }
            }
         }
         return total;
      }
      
      protected function getNumberOfSafePurchases(recipeItem:RecipeItem) : int
      {
         var marketStallTotal:int = 0;
         var craftingSiloTotal:int = 0;
         var unsharableTotal:int = 0;
         var marketStallMaxCapacity:int = 0;
         var marketStallCurrentCapacity:int = 0;
         var craftingSiloMaxCapacity:int = 0;
         var craftingSiloCurrentCapacity:int = 0;
         var unsharableMaxCapacity:int = 0;
         var unsharableCurrentCapacity:int = 0;
         var numberOfSafeUnsharableBushelPurchases:int = 0;
         var smallestNumberOfSafeUnsharableBushelPurchases:int = 0;
         var ingredient:Object = null;
         var numUnsharableBushelsInQueues:int = 0;
         var maxNumSafeMarketStallPurchases:int = 0;
         var maxNumSafeCraftingSiloPurchases:int = 0;
         var maxNumSafeUnsharablePurchases:int = 0;
         var numberOfSafePurchases:int = 0;
         if(recipeItem.recipeType == CraftingConstants.LABTYPE_RECIPE)
         {
            numberOfSafePurchases = Global.farmGameSettingsManager.getAttribute("LabMaxSafePurchases",10);
         }
         else
         {
            marketStallTotal = this.getNumberOfBushelsOfTypeInRecipe(recipeItem,BUSHEL_TYPE_STALL);
            craftingSiloTotal = this.getNumberOfBushelsOfTypeInRecipe(recipeItem,BUSHEL_TYPE_SILO);
            unsharableTotal = this.getNumberOfBushelsOfTypeInRecipe(recipeItem,BUSHEL_TYPE_UNSHARABLE);
            marketStallMaxCapacity = Global.player.craftingState.inventoryState.maxCapacity;
            marketStallCurrentCapacity = Global.player.craftingState.inventoryState.currentCapacity;
            marketStallCurrentCapacity = Math.min(marketStallMaxCapacity,marketStallCurrentCapacity);
            craftingSiloMaxCapacity = Global.player.craftingState.inventoryState.craftingSiloMaxCapacity;
            craftingSiloCurrentCapacity = Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity;
            craftingSiloCurrentCapacity = Math.min(craftingSiloMaxCapacity,craftingSiloCurrentCapacity);
            unsharableMaxCapacity = CraftingInventoryStateV2.MAX_UNSHARABLE_BUSHEL_CAPACITY;
            unsharableCurrentCapacity = Global.player.craftingState.inventoryState.numUnsharableBushels;
            unsharableCurrentCapacity = Math.min(unsharableMaxCapacity,unsharableCurrentCapacity);
            numberOfSafeUnsharableBushelPurchases = 0;
            smallestNumberOfSafeUnsharableBushelPurchases = int.MAX_VALUE;
            for each(ingredient in recipeItem.ingredients)
            {
               if(this.getCraftTypeofBushel(ingredient.itemCode) == BUSHEL_TYPE_UNSHARABLE)
               {
                  numberOfSafeUnsharableBushelPurchases = (CraftingConstants.MAX_INDIVIDUAL_UNSHARABLE_BUSHEL_LIMIT - this.getBushelQuantityInInventory(ingredient.itemCode)) / ingredient.quantityRequired;
                  smallestNumberOfSafeUnsharableBushelPurchases = Math.min(numberOfSafeUnsharableBushelPurchases,smallestNumberOfSafeUnsharableBushelPurchases);
                  smallestNumberOfSafeUnsharableBushelPurchases = Math.max(smallestNumberOfSafeUnsharableBushelPurchases,0);
               }
            }
            numUnsharableBushelsInQueues = getNumBushelsOfSubtypeInQueues(CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE);
            maxNumSafeMarketStallPurchases = marketStallTotal > 0 ? int((marketStallMaxCapacity - marketStallCurrentCapacity) / marketStallTotal) : int.MAX_VALUE;
            maxNumSafeCraftingSiloPurchases = craftingSiloTotal > 0 ? int((craftingSiloMaxCapacity - craftingSiloCurrentCapacity) / craftingSiloTotal) : int.MAX_VALUE;
            maxNumSafeUnsharablePurchases = unsharableTotal > 0 ? int((unsharableMaxCapacity - (unsharableCurrentCapacity + numUnsharableBushelsInQueues)) / unsharableTotal) : int.MAX_VALUE;
            numberOfSafePurchases = Math.min(maxNumSafeMarketStallPurchases,maxNumSafeCraftingSiloPurchases,maxNumSafeUnsharablePurchases,smallestNumberOfSafeUnsharableBushelPurchases);
            if(numberOfSafePurchases == 0)
            {
               switch(numberOfSafePurchases)
               {
                  case maxNumSafeMarketStallPurchases:
                     numberOfSafePurchases = NO_MARKET_STALL_ROOM;
                     break;
                  case maxNumSafeCraftingSiloPurchases:
                     numberOfSafePurchases = NO_CRAFTING_SILO_ROOM;
                     break;
                  case maxNumSafeUnsharablePurchases:
                     numberOfSafePurchases = NO_UNSHARABLE_INVENTORY_ROOM;
                     break;
                  case smallestNumberOfSafeUnsharableBushelPurchases:
                     numberOfSafePurchases = NO_UNSHARABLE_INVENTORY_ROOM;
               }
            }
         }
         return numberOfSafePurchases;
      }
      
      public function onPurchaseBundle(recipeCode:String, amount:int) : void
      {
         var ingredient:Object = null;
         var beginOOS_itemsStr:String = null;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeCode);
         var totalPrice:int = this.getTotalBushelPrice(recipeItem) * amount;
         if(Global.player.cash >= totalPrice)
         {
            Global.player.cash -= totalPrice;
            for each(ingredient in recipeItem.ingredients)
            {
               if(!(ingredient.hasOwnProperty(RecipeItem.SWAPPABLE) && ingredient[RecipeItem.SWAPPABLE] == true))
               {
                  this.addItemToInventory(ingredient.itemCode,amount * ingredient.quantityRequired);
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
                  {
                     beginOOS_itemsStr = "item_" + ingredient.itemCode + ":" + amount * ingredient.quantityRequired;
                     FarmStatsManager.count("beginOOS","client","add_onPurchaseBundle",beginOOS_itemsStr);
                  }
               }
            }
            TransactionManager.addTransaction(new TBuyBushelBundle(recipeItem.id,amount),true);
            if(this.m_purchaseDialogCallback != null)
            {
               this.m_purchaseDialogCallback(recipeItem.id);
               this.m_purchaseDialogCallback = null;
            }
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_CASH,"impulseBuyPopup",totalPrice,recipeItem.name);
         }
      }
      
      private function purchaseBushelHelper(bushelItem:FarmItem, bushelCost:int, quantity:int = 1, recipeId:String = "", performImmediately:Boolean = false) : void
      {
         var completeCost:int = bushelCost * quantity;
         if(Global.player.cash >= completeCost)
         {
            Global.player.cash -= completeCost;
            this.addItemToInventory(bushelItem.code,quantity);
            TransactionManager.addTransaction(new TBuyBushel(bushelItem.code,quantity,recipeId),performImmediately);
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_CASH,"impulseBuyPopup",completeCost,bushelItem.friendlyTitle);
         }
      }
      
      public function onPurchaseRemainingItemsToCompleteRecipe(recipeItem:RecipeItem) : void
      {
         var ingredient:Object = null;
         var item:FarmItem = null;
         var i:int = 0;
         var required:int = 0;
         var have:int = 0;
         var differnce:int = 0;
         for each(ingredient in recipeItem.ingredients)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
            required = int(ingredient.quantityRequired);
            have = this.getInventoryCountHelper(item.code,required,recipeItem.craft);
            differnce = required - have > 0 ? int(required - have) : 0;
            for(i = 0; i < differnce; i++)
            {
               this.onPurchaseBushel(item.code);
            }
         }
      }
      
      public function getRemainingItemsToCompleteRecipePrice(recipeItem:RecipeItem) : int
      {
         var ingredient:Object = null;
         var item:FarmItem = null;
         var required:int = 0;
         var have:int = 0;
         var differnce:int = 0;
         var cost:int = 0;
         for each(ingredient in recipeItem.ingredients)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
            required = int(ingredient.quantityRequired);
            have = this.getInventoryCountHelper(item.code,required,recipeItem.craft);
            differnce = required - have > 0 ? int(required - have) : 0;
            cost += item.cash * differnce;
         }
         return cost;
      }
      
      public function onPurchaseBushel(bushel:String, recipeId:String = "", quantity:int = 1, performImmediately:Boolean = true) : Boolean
      {
         var numUnsharableBushels:int = 0;
         var numUnsharableBushelsInQueues:int = 0;
         var recipeItem:RecipeItem = null;
         var inventoryState:CraftingInventoryStateV2 = Global.player.craftingState.inventoryState;
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bushel);
         var bushelType:int = this.getCraftTypeofBushel(bushel);
         var maxCapacity:Number = inventoryState.maxCapacity;
         var currentCapacity:Number = inventoryState.currentCapacity;
         var bushelCost:int = Global.farmGameSettingsManager.getAttribute(bushelItem.name + "Price",1);
         if(bushelType == CraftingManager.BUSHEL_TYPE_LAB)
         {
            this.purchaseBushelHelper(bushelItem,bushelCost,quantity,recipeId,performImmediately);
         }
         else if(bushelType == BUSHEL_TYPE_UNSHARABLE)
         {
            numUnsharableBushels = inventoryState.numUnsharableBushels;
            numUnsharableBushelsInQueues = getNumBushelsOfSubtypeInQueues(CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE);
            if(!(numUnsharableBushels + numUnsharableBushelsInQueues < CraftingInventoryStateV2.MAX_UNSHARABLE_BUSHEL_CAPACITY && this.getBushelQuantityInInventory(bushelItem.code) < CraftingConstants.MAX_INDIVIDUAL_UNSHARABLE_BUSHEL_LIMIT || bushel == "zy5" || bushel == "vwyl"))
            {
               recipeItem = null;
               if(recipeId != "")
               {
                  recipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
               }
               displayUnsharableBushelLimitDialog(recipeItem,bushelItem);
               return false;
            }
            bushelCost = this.getBushelPrice(bushelItem);
            this.purchaseBushelHelper(bushelItem,bushelCost,quantity,recipeId,performImmediately);
         }
         else if(bushelType == BUSHEL_TYPE_VILLAGE)
         {
            maxCapacity = inventoryState.villageStorageMaxCapacity;
            currentCapacity = inventoryState.villageStorageCurrentCapacity;
            if(currentCapacity + quantity <= maxCapacity)
            {
               this.purchaseBushelHelper(bushelItem,1,quantity,recipeId,performImmediately);
            }
         }
         else
         {
            if(bushelType == CraftingManager.BUSHEL_TYPE_SILO)
            {
               maxCapacity = inventoryState.craftingSiloMaxCapacity;
               currentCapacity = inventoryState.craftingSiloCurrentCapacity;
            }
            if(currentCapacity + quantity > maxCapacity)
            {
               if(bushelType == CraftingManager.BUSHEL_TYPE_SILO)
               {
                  UI.displayMessage(ZLocUtils.t("Crafting",maxCapacity == 0 ? "BushelBundleBuyNoCraftingSilo" : "BushelBundleBuyNoRoomInCraftingSilo"),0,this.m_closePurchaseDialogCallback,"",true);
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Crafting","BushelBundleBuyNoRoom"),0,this.m_closePurchaseDialogCallback,"",true);
               }
               return false;
            }
            this.purchaseBushelHelper(bushelItem,1,quantity,recipeId,performImmediately);
         }
         return true;
      }
      
      public function getBushelPrice(bushel:FarmItem) : int
      {
         var cashXMLValue:int = 0;
         var result:int = DEFAULT_BUSHEL_PRICE;
         if(bushel)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               cashXMLValue = bushel.getIntFromDataSource("cash");
            }
            else
            {
               cashXMLValue = int(bushel.xml.cash);
            }
            if(cashXMLValue > 0)
            {
               result = cashXMLValue;
            }
         }
         return result;
      }
      
      public function getTotalBushelPrice(recipe:RecipeItem) : int
      {
         var item:FarmItem = null;
         var ingredient:Object = null;
         var bundleCost:int = 0;
         if(recipe.recipeType == CraftingConstants.LABTYPE_RECIPE)
         {
            for each(ingredient in recipe.ingredients)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
               bundleCost += Global.farmGameSettingsManager.getAttribute(item.name + "Price",DEFAULT_BUSHEL_PRICE) * int(ingredient.quantityRequired);
            }
         }
         else if(recipe.useBushelCountPrice)
         {
            for each(ingredient in recipe.ingredients)
            {
               if(!(ingredient.hasOwnProperty(RecipeItem.SWAPPABLE) && ingredient[RecipeItem.SWAPPABLE] == true))
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
                  bundleCost += this.getBushelPrice(item) * int(ingredient.quantityRequired);
               }
            }
         }
         else
         {
            bundleCost = Global.farmGameSettingsManager.getAttribute("bushelBundlePrice",DEFAULT_RECIPE_BUNDLE_PRICE);
         }
         var discountFactor:Number = Number(LabBuildingManager.getInstance().getDiscountFactor(recipe.craft));
         if(discountFactor)
         {
            bundleCost = Math.round(bundleCost - bundleCost * discountFactor);
         }
         return bundleCost;
      }
      
      public function onClosePurchaseDialog() : void
      {
         if(this.m_closePurchaseDialogCallback != null)
         {
            this.m_closePurchaseDialogCallback();
            this.m_closePurchaseDialogCallback = null;
         }
      }
      
      public function beginClaimMarketStallItemFromFriend(uid:String, itemCode:String) : void
      {
         var beginOOS_itemsStr:String = null;
         var item:FarmItem = null;
         this.addItemToInventory(itemCode,1);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
         {
            beginOOS_itemsStr = "item_" + itemCode + ":" + 1;
            FarmStatsManager.count("beginOOS","client","add_ClaimMarketStallFriend",beginOOS_itemsStr);
         }
         Global.player.craftingState.checkCraftingRollOver();
         var shoppingState:ShoppingState = Global.player.craftingState.shoppingState;
         shoppingState.addBagsUsed(uid,1);
         var transaction:TClaimMarketStallItem = new TClaimMarketStallItem(String(uid),itemCode,this.endClaimMarketStallItemFromFriend);
         TransactionManager.addTransaction(transaction);
         CraftingStatsManager.recordBushelTaken();
         if(SmartBushelHelper.inExperiment())
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(Boolean(item) && Boolean(item.name))
            {
               FarmStatsManager.sample(100,"craftingBooster","bushel_tracking",item.name);
            }
         }
      }
      
      public function endClaimMarketStallItemFromFriend(uid:String, itemCode:String, responseCode:int) : void
      {
         var shoppingState:ShoppingState = null;
         var beginOOS_itemsStr:String = null;
         var item:FarmItem = null;
         if(responseCode != TClaimMarketStallItem.CLAIMED_OK)
         {
            this.deductItemFromCraftingInventory(itemCode);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS2) > 0)
            {
               beginOOS_itemsStr = "item_" + itemCode + ":1";
               FarmStatsManager.count("beginOOS","client","deduct_ClaimMarketStall",beginOOS_itemsStr);
            }
            Global.player.craftingState.checkCraftingRollOver();
            shoppingState = Global.player.craftingState.shoppingState;
            shoppingState.addBagsUsed(uid,-1);
            this.renderMarketStallErrorPopup(uid,itemCode,responseCode);
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_GET_BUSHEL_FRIEND_STAT) > 0)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            StatsManager.count("marketstall","getbushel_friend",item.name,uid);
         }
      }
      
      public function canPurchaseFromUser(uid:String) : Boolean
      {
         var result:Boolean = true;
         var shoppingState:ShoppingState = Global.player.craftingState.shoppingState;
         var inventoryState:CraftingInventoryStateV2 = Global.player.craftingState.inventoryState;
         if(shoppingState.getTotalDailyPurchases() >= shoppingState.maxPurchasesPerDay)
         {
            result = false;
         }
         if(inventoryState.isFull)
         {
            result = false;
         }
         if(shoppingState.getBagsUsedByUser(uid) >= shoppingState.maxBagsPerUser)
         {
            result = false;
         }
         return result;
      }
      
      public function timeToNextBushelFromUser(uid:String) : Number
      {
         return this.canPurchaseFromUser(uid) ? 0 : Global.player.craftingState.getTimeToNextRollOver();
      }
      
      public function timeToNextPurchaseFromUser(uid:String) : Number
      {
         return this.canPurchaseCraftingGoodFromUser(uid) ? 0 : Global.player.craftingState.getTimeToNextRollOver();
      }
      
      public function canPurchaseCraftingGoodFromUser(uid:String) : Boolean
      {
         var result:Boolean = true;
         var shoppingState:ShoppingState = Global.player.craftingState.shoppingState;
         var inventoryState:CraftingInventoryStateV2 = Global.player.craftingState.inventoryState;
         if(shoppingState.getTotalDailyCraftingPurchases() >= shoppingState.maxCraftingPurchasesPerDay)
         {
            result = false;
         }
         if(shoppingState.getCraftingBagsUsedByUser(uid) >= shoppingState.maxCraftingBagsPerUser)
         {
            result = false;
         }
         return result;
      }
      
      public function getFriendlyTimeArrayToMoreBags() : Array
      {
         return FarmGameUtil.parseTimeLeft(Global.player.craftingState.getTimeToNextRollOver());
      }
      
      public function getFriendlyTimeToMoreBags() : String
      {
         var friendlyTime:String = null;
         var timeAmounts:Array = FarmGameUtil.parseTimeLeft(Global.player.craftingState.getTimeToNextRollOver());
         if(timeAmounts[0] > 0)
         {
            friendlyTime = ZLocUtils.t("SocialMission","General_FriendlyTimeDaysHours",{
               "days":timeAmounts[0],
               "day_word":ZLocUtils.tk("SocialMission","day_word","",timeAmounts[0]),
               "hrs":timeAmounts[1],
               "hr_word":ZLocUtils.tk("SocialMission","hr_word","",timeAmounts[1])
            });
         }
         else if(timeAmounts[1] > 0)
         {
            friendlyTime = ZLocUtils.t("SocialMission","General_FriendlyTimeHoursMins",{
               "hrs":timeAmounts[1],
               "hr_word":ZLocUtils.tk("SocialMission","hr_word","",timeAmounts[1]),
               "mins":timeAmounts[2],
               "min_word":ZLocUtils.tk("SocialMission","min_word","",timeAmounts[2])
            });
         }
         else if(timeAmounts[2] > 0)
         {
            friendlyTime = ZLocUtils.t("SocialMission","General_FriendlyTimeMinsSecs",{
               "mins":timeAmounts[2],
               "min_word":ZLocUtils.tk("SocialMission","min_word","",timeAmounts[2]),
               "secs":timeAmounts[3],
               "sec_word":ZLocUtils.tk("SocialMission","sec_word","",timeAmounts[3])
            });
         }
         else
         {
            friendlyTime = ZLocUtils.t("SocialMission","General_FriendlyTimeSecs",{
               "secs":timeAmounts[3],
               "sec_word":ZLocUtils.tk("SocialMission","sec_word","",timeAmounts[3])
            });
         }
         return friendlyTime;
      }
      
      public function getBagsAvailableByUser(uid:String) : int
      {
         var shoppingState:ShoppingState = Global.player.craftingState.shoppingState;
         var allowed:int = shoppingState.maxBagsPerUser;
         var consumed:int = shoppingState.getBagsUsedByUser(uid);
         return int(Math.max(0,allowed - consumed));
      }
      
      public function getCraftingBagsAvailableByUser(uid:String) : int
      {
         var shoppingState:ShoppingState = Global.player.craftingState.shoppingState;
         var allowed:int = shoppingState.maxCraftingBagsPerUser;
         var consumed:int = shoppingState.getCraftingBagsUsedByUser(uid);
         return int(Math.max(0,allowed - consumed));
      }
      
      public function consumeBushelForBuff(bushelItemCode:String) : Boolean
      {
         var item:FarmItem = null;
         var consumable:Consumable = null;
         var beginOOS_itemsStr:String = null;
         var result:Boolean = false;
         var existingBuff:BBushel = null;
         if(Global.player.buffs["BBushel"] != null)
         {
            existingBuff = new BBushel("BBushel");
         }
         if(existingBuff != null && !existingBuff.isExpired())
         {
            existingBuff.unapply();
         }
         if(this.deductItemFromCraftingInventory(bushelItemCode))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS2) > 0)
            {
               beginOOS_itemsStr = "item_" + bushelItemCode + ":1";
               FarmStatsManager.count("beginOOS","client","deduct_consumeBushelForBuff",beginOOS_itemsStr);
            }
            item = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
            consumable = Consumable.createConsumable(item.name);
            consumable.consume(false,true,"",false,StorageInventoryType.PERSONAL_CRAFTING_INVENTORY);
            result = true;
         }
         return result;
      }
      
      public function consumeBushelForPigpenSlop(bushelItemCode:String) : Boolean
      {
         var beginOOS_itemsStr:String = null;
         var result:Boolean = false;
         var existingBuff:BBushel = null;
         if(Global.player.buffs["BBushel"] != null)
         {
            existingBuff = new BBushel("BBushel");
         }
         if(existingBuff != null && !existingBuff.isExpired())
         {
            existingBuff.unapply();
         }
         if(this.deductItemFromCraftingInventory(bushelItemCode))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS2) > 0)
            {
               beginOOS_itemsStr = "item_" + bushelItemCode + ":1";
               FarmStatsManager.count("beginOOS","client","deduct_consumeBushelForPigpenSlop",beginOOS_itemsStr);
            }
            result = true;
         }
         return result;
      }
      
      private function harvestedCraftingSiloBushel(craftingSiloId:int, openSiloRewardUrl:String, bushelItemCode:String, quantity:Number) : void
      {
         var bushelItem:FarmItem = null;
         var task:CraftingBushelSummaryTask = null;
         if(craftingSiloId)
         {
            if(Global.world.getObjectById(craftingSiloId) != null)
            {
               bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
               this.addToBushelSummaryQueue(bushelItem,null,openSiloRewardUrl,quantity);
               task = new CraftingBushelSummaryTask();
               task.submit();
            }
         }
      }
      
      public function shareBushel(bushelItemCode:String, quantity:int, bundleId:String = "CraftingShareFromStall", deductBushels:Boolean = true, rewardUrl:String = null) : Boolean
      {
         var beginOOS_itemsStr:String = null;
         var bushelItem:FarmItem = null;
         var t:TShareBushels = null;
         var result:Boolean = false;
         var shouldShare:Boolean = true;
         if(deductBushels)
         {
            shouldShare = this.getBushelQuantityInInventory(bushelItemCode) >= quantity && this.deductItemFromCraftingInventory(bushelItemCode,quantity);
         }
         if(shouldShare)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS2) > 0)
            {
               beginOOS_itemsStr = "item_" + bushelItemCode + ":" + quantity;
               FarmStatsManager.count("beginOOS","client","deduct_shareBushel",beginOOS_itemsStr);
            }
            if(Boolean(Global.flashHotParams["FE_FREE_BUSHEL_EXPLOIT_FIX_TEMPRT"]) && !deductBushels)
            {
               bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
               CraftingManager.getInstance().displayShareMarketStallFeed(bushelItem,quantity,rewardUrl,bundleId);
            }
            else
            {
               t = new TShareBushels(bushelItemCode,quantity,null,bundleId,deductBushels);
               TransactionManager.addTransaction(t,true);
            }
            result = true;
         }
         return result;
      }
      
      private function renderMarketStallErrorPopup(uid:String, itemCode:String, responseCode:int) : void
      {
         var friend:Friend = Global.friendManager.getFriendData(uid);
         var friendGender:String = Global.friendManager.getFriendGender(uid);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var message:String = "";
         switch(responseCode)
         {
            case TClaimMarketStallItem.BUSHEL_EXPIRED:
               message = ZLocUtils.t("Crafting","Errors_ClaimBushelBushelExpired",{
                  "friend":ZLocUtils.tn(friend.name,ZLocUtils.tg(friendGender)),
                  "item":ZLocUtils.tk_pk(item.friendlyName)
               });
               break;
            case TClaimMarketStallItem.BUSHEL_NOT_FOUND:
               message = ZLocUtils.t("Crafting","Errors_ClaimBushelBushelNotFound",{
                  "friend":ZLocUtils.tn(friend.name,ZLocUtils.tg(friendGender)),
                  "item":ZLocUtils.tk_pk(item.friendlyName)
               });
               break;
            case TClaimMarketStallItem.BAGS_EXHAUSTED:
               message = ZLocUtils.t("Crafting","Errors_ClaimBushelBagExhausted");
               break;
            case TClaimMarketStallItem.SILO_FULL:
               message = ZLocUtils.t("Crafting","Errors_ClaimBushelBushelSiloFull",{
                  "friend":ZLocUtils.tn(friend.name,ZLocUtils.tg(friendGender)),
                  "item":ZLocUtils.tk_pk(item.friendlyName)
               });
               break;
            default:
               message = ZLocUtils.t("Crafting","Errors_ClaimBushelBushelOther",{
                  "friend":ZLocUtils.tn(friend.name,ZLocUtils.tg(friendGender)),
                  "item":ZLocUtils.tk_pk(item.friendlyName)
               });
         }
         var popup:GenericPopup = new GenericPopup(message,GenericPopup.TYPE_OK);
         UI.displayPopup(popup,false);
      }
      
      public function closeMarketStall(marketStallBuilding:MarketStallBuilding) : void
      {
         TransactionManager.addTransaction(new TCloseMarketStall(marketStallBuilding.getId()));
         marketStallBuilding.closeStall();
      }
      
      public function getAllCraftingSilosCount() : int
      {
         return this.getPlacedCraftingSilos() + this.getCraftingSilosInGiftBox();
      }
      
      public function getCraftingSilosInGiftBox() : int
      {
         var thisGift:StorageItem = null;
         var thisGiftItem:FarmItem = null;
         var gifts:Array = Global.player.getGifts();
         var total:int = 0;
         for(var i:int = 0; i < gifts.length; i++)
         {
            thisGift = gifts[i] as StorageItem;
            thisGiftItem = thisGift.item;
            if(thisGiftItem.name == "craftingsilo")
            {
               total += int(thisGift.quantity);
            }
         }
         return total;
      }
      
      public function getPlacedCraftingSilos() : int
      {
         return this.getCraftingSilosInWorld().length;
      }
      
      public function getCraftingSilosInWorld() : Array
      {
         return Global.world.getObjectsByName("craftingsilo");
      }
      
      public function getAllMarketStallsCount() : int
      {
         return this.getPlacedMarketStalls() + this.getMarketStallsInGiftBox();
      }
      
      public function getMarketStallsInGiftBox() : int
      {
         var thisGift:StorageItem = null;
         var thisGiftItem:FarmItem = null;
         var gifts:Array = Global.player.getGifts();
         var total:int = 0;
         for(var i:int = 0; i < gifts.length; i++)
         {
            thisGift = gifts[i] as StorageItem;
            thisGiftItem = thisGift.item;
            if(thisGiftItem.className == "MarketStallBuilding")
            {
               total += int(thisGift.quantity);
            }
         }
         return total;
      }
      
      public function getPlacedMarketStalls() : int
      {
         return this.getMarketStallsInWorld().length;
      }
      
      public function getMarketStallsInWorld() : Array
      {
         var results:Array = new Array();
         var objectClass:Class = getDefinitionByName("Classes.MarketStallBuilding") as Class;
         if(objectClass != null)
         {
            results = Global.world.getObjectsByClass(objectClass);
         }
         return results;
      }
      
      public function getCraftTypeFriendlyName(craft:String) : String
      {
         return "Crafting:CraftChosen_FriendSlotTitle_" + craft;
      }
      
      public function getCottageFriendlyNameByCraft(craft:String) : String
      {
         return "Items:crafting" + craft + "_friendlyName";
      }
      
      public function getCottageByCraft(craft:String) : CraftingCottageBuilding
      {
         var cottage:CraftingCottageBuilding = null;
         var result:CraftingCottageBuilding = null;
         var craftingCottages:Array = this.getPlacedCraftingCottages();
         for each(cottage in craftingCottages)
         {
            if(cottage.craftType == craft)
            {
               result = cottage;
               break;
            }
         }
         return result;
      }
      
      public function getCottageByRecipe(recipeId:String) : CraftingCottageBuilding
      {
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var cottage:CraftingCottageBuilding = null;
         if(Boolean(recipe) && Boolean(recipe.craft))
         {
            cottage = this.getCottageByCraft(recipe.craft);
         }
         return cottage;
      }
      
      public function getMarketStallByBushel(bushelCode:String) : MarketStallBuilding
      {
         var instances:Array = null;
         var i:int = 0;
         var thisBuilding:MarketStallBuilding = null;
         var result:MarketStallBuilding = null;
         var objectClass:Class = getDefinitionByName("Classes.MarketStallBuilding") as Class;
         if(objectClass != null)
         {
            instances = Global.world.getObjectsByClass(objectClass);
            for(i = 0; i < instances.length; i++)
            {
               thisBuilding = instances[i];
               if(thisBuilding.bushelItemCode == bushelCode)
               {
                  result = thisBuilding;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getMarketStallNearestExpiration() : MarketStallBuilding
      {
         var instances:Array = null;
         var i:int = 0;
         var thisBuilding:MarketStallBuilding = null;
         var result:MarketStallBuilding = null;
         var nearestExpirationTime:Number = -1;
         var objectClass:Class = getDefinitionByName("Classes.MarketStallBuilding") as Class;
         if(objectClass != null)
         {
            instances = Global.world.getObjectsByClass(objectClass);
            for(i = 0; i < instances.length; i++)
            {
               thisBuilding = instances[i];
               if(nearestExpirationTime == -1 || thisBuilding.serverTimeClosed <= nearestExpirationTime)
               {
                  result = thisBuilding;
                  nearestExpirationTime = thisBuilding.serverTimeClosed;
               }
            }
         }
         return result;
      }
      
      public function getMarketStallMax() : int
      {
         var farmItem:FarmItem = null;
         var item:XML = null;
         var max:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(MARKET_STALL_ITEM_CODE);
            if(farmItem)
            {
               max = farmItem.totalTiers;
            }
         }
         else
         {
            item = Global.farmGameSettingsManager.getItemXMLByCode(MARKET_STALL_ITEM_CODE);
            if(item != null)
            {
               max = int(item.@totalTiers);
            }
         }
         return max;
      }
      
      public function hasMaximumNumberOfStallsPlaced() : Boolean
      {
         return this.getAllMarketStallsCount() >= this.getMarketStallMax();
      }
      
      public function incrementOpenPopups() : void
      {
         ++this.m_popupCount;
      }
      
      public function decrementOpenPopups() : void
      {
         --this.m_popupCount;
         this.m_popupCount = int(Math.max(this.m_popupCount,0));
         if(this.m_popupCount == 0)
         {
            UI.stopPopups(false);
         }
      }
      
      public function beginSendThankYouFeed(bushelItemCode:String, stallOwner:String, callBack:Function, thankYouFeedBundle:String) : void
      {
         var delegate:Function = function(rewardUrl:String):void
         {
            endSendThankYouFeed(bushelItemCode,stallOwner,rewardUrl,callBack,thankYouFeedBundle);
         };
         var transaction:TGetMarketStallRewardUrl = new TGetMarketStallRewardUrl(bushelItemCode,String(stallOwner),delegate);
         TransactionManager.addTransaction(transaction,true);
      }
      
      private function endSendThankYouFeed(bushelItemCode:String, stallOwner:String, rewardUrl:String, callBack:Function, thankYouFeedBundle:String) : void
      {
         var item:FarmItem = null;
         var feed:MarketThankYouFeed = null;
         if(callBack != null)
         {
            callBack();
         }
         if(rewardUrl != null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
            feed = new MarketThankYouFeed(item.friendlyName,item.icon,stallOwner,rewardUrl,thankYouFeedBundle);
            feed.publish();
         }
      }
      
      public function getCoinRewardForRewardPoints(points:int) : Number
      {
         var craftingConfig:XML = Global.farmGameSettingsManager.getCraftingConfig();
         var increment:int = int(craftingConfig.rewards.coins.increment);
         return increment * points;
      }
      
      public function getFuelRewardForRewardPoints(points:int) : Number
      {
         var craftingConfig:XML = Global.farmGameSettingsManager.getCraftingConfig();
         var increment:int = int(craftingConfig.rewards.fuel.increment);
         return increment * points;
      }
      
      public function getXpRewardForRewardPoints(points:int) : Number
      {
         var craftingConfig:XML = Global.farmGameSettingsManager.getCraftingConfig();
         var increment:int = int(craftingConfig.rewards.xp.increment);
         return increment * points;
      }
      
      public function spendRewardPoints(totalPoints:int, selection:int) : void
      {
         var thisReward:PendingReward = null;
         var remainingPoints:* = totalPoints;
         for(var i:int = 0; i < Global.player.craftingState.pendingRewards.length; i++)
         {
            if(remainingPoints == 0)
            {
               break;
            }
            thisReward = Global.player.craftingState.pendingRewards[i];
            if(!thisReward.claimed)
            {
               thisReward.claimed = true;
               remainingPoints--;
            }
         }
         var newRewards:Array = new Array();
         for(i = 0; i < Global.player.craftingState.pendingRewards.length; i++)
         {
            if(remainingPoints == 0)
            {
               break;
            }
            thisReward = Global.player.craftingState.pendingRewards[i];
            if(!thisReward.claimed)
            {
               newRewards.push(thisReward);
            }
         }
         Global.player.craftingState.pendingRewards = newRewards;
         var actualPoints:int = totalPoints - remainingPoints;
         var transaction:TClaimMarketReward = new TClaimMarketReward(actualPoints,selection);
         TransactionManager.addTransaction(transaction);
         switch(selection)
         {
            case CraftingConstants.REWARD_PICK_COINS:
               this.performRewardCoins(actualPoints);
               break;
            case CraftingConstants.REWARD_PICK_FUEL:
               this.performRewardFuel(actualPoints);
               break;
            case CraftingConstants.REWARD_PICK_XP:
               this.performRewardXp(actualPoints);
         }
      }
      
      private function performRewardCoins(pickPoints:int) : void
      {
         var amount:Number = this.getCoinRewardForRewardPoints(pickPoints);
         Global.player.updateWorldCurrency(Currency.GOLD,amount,true);
         Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_MarketStallAddCoins",{"quantity":amount}));
      }
      
      private function performRewardFuel(pickPoints:int) : void
      {
         var amount:Number = this.getFuelRewardForRewardPoints(pickPoints);
         Global.player.energy += amount;
         Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_MarketStallAddEnergy",{"quantity":amount}));
      }
      
      private function performRewardXp(pickPoints:int) : void
      {
         var amount:Number = Global.player.calculateAndAddXp(this.getXpRewardForRewardPoints(pickPoints));
         Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_MarketStallAddXP",{"quantity":amount}));
      }
      
      public function displayBushelsInformationToaster() : void
      {
         var newBushelsFoundSummaryQueue:Array = null;
         var bushelSummary:BushelsFoundSummary = null;
         var bushelCraftType:int = 0;
         var localizedBushelMessage:String = null;
         var localizedBushelTitle:String = null;
         if(this.bushelsFoundSummaryQueue.length > 0 && null == this.m_bushelInfoWindow)
         {
            newBushelsFoundSummaryQueue = new Array();
            for each(bushelSummary in this.bushelsFoundSummaryQueue)
            {
               if(bushelSummary.rewardUrl)
               {
                  bushelCraftType = this.getCraftTypeofBushel(bushelSummary.bushelItem.code);
                  if(bushelCraftType == CraftingManager.BUSHEL_TYPE_SILO)
                  {
                     this.m_siloBushelDialogSummaryQueue.push(bushelSummary);
                  }
                  else
                  {
                     newBushelsFoundSummaryQueue.push(bushelSummary);
                  }
               }
               else
               {
                  localizedBushelMessage = ZLocUtils.t("Crafting","BushelSummary_Text",{
                     "item":ZLocUtils.tk_pk(bushelSummary.bushelItem.friendlyName),
                     "quantity":this.getTimeStallIsOpenFor(bushelSummary)
                  });
                  localizedBushelTitle = ZLocUtils.t("Crafting","BushelSummary_Title",{"quantity":bushelSummary.quantity});
                  ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(localizedBushelTitle,localizedBushelMessage,bushelSummary.bushelItem.icon,"",ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8)));
               }
            }
            if(newBushelsFoundSummaryQueue.length > 0)
            {
               this.m_bushelInfoWindow = new BushelInfoWindow(ArrayUtil.copyArray(newBushelsFoundSummaryQueue));
               this.m_bushelInfoWindow.addEventListener(CloseEvent.CLOSE,this.onBushelInfoWindowClose);
               UI.displayPopup(this.m_bushelInfoWindow,false);
               UI.stopPopups(true);
            }
            if(bushelCraftType == CraftingManager.BUSHEL_TYPE_SILO)
            {
               this.conditionalLaunchSiloBushelSummaryDialog();
            }
            CraftingManager.getInstance().flushBushelFoundSummaryQueue();
         }
      }
      
      protected function getTimeStallIsOpenFor(bushelSummary:BushelsFoundSummary) : int
      {
         var baseTime:int = 24;
         var additionalHours:int = Global.getStarsForMastery(bushelSummary.bushelItem.crop) * 8;
         return int(baseTime + additionalHours);
      }
      
      private function onBushelInfoWindowClose(event:Event) : void
      {
         if(this.m_bushelInfoWindow)
         {
            this.m_bushelInfoWindow.removeEventListener(CloseEvent.CLOSE,this.onBushelInfoWindowClose);
            this.m_bushelInfoWindow = null;
            UI.stopPopups(false);
         }
      }
      
      public function getBushelMarketIconForBushel(bushelItemCode:String) : String
      {
         return Global.farmGameSettingsManager.getImageByNameAndItemCode(bushelItemCode,CraftingConstants.MARKET_FULL_IMAGE_NAME);
      }
      
      public function displayShareMarketStallFeed(bushelItem:FarmItem, quantity:int, rewardUrl:String, bundleId:String, overrideIconUrl:String = null, craftedItem:String = null) : void
      {
         var feed:ShareMarketStallFeed = new ShareMarketStallFeed(bushelItem,quantity,rewardUrl,bundleId,overrideIconUrl,craftedItem);
         feed.publish();
      }
      
      private function addToBushelSummaryQueue(bushelItem:FarmItem, marketStall:MarketStallBuilding, rewardUrl:String, quantity:Number) : void
      {
         var summary:BushelsFoundSummary = this.getBushelFoundSummaryFromQueue(bushelItem);
         if(summary)
         {
            summary.quantity += quantity;
         }
         else
         {
            summary = new BushelsFoundSummary(bushelItem,marketStall,quantity,rewardUrl);
            this.m_bushelsFoundSummaryQueue.push(summary);
         }
      }
      
      private function getBushelFoundSummaryFromQueue(bushelItem:FarmItem) : BushelsFoundSummary
      {
         var summary:BushelsFoundSummary = null;
         for each(summary in this.bushelsFoundSummaryQueue)
         {
            if(summary.bushelItem.code == bushelItem.code)
            {
               return summary;
            }
         }
         return null;
      }
      
      public function get bushelsFoundSummaryQueue() : Array
      {
         return this.m_bushelsFoundSummaryQueue;
      }
      
      public function flushBushelFoundSummaryQueue() : void
      {
         var key:* = undefined;
         for(key in this.m_bushelsFoundSummaryQueue)
         {
            this.m_bushelsFoundSummaryQueue[key] = null;
         }
         this.m_bushelsFoundSummaryQueue = new Array();
      }
      
      public function showCraftPreorderReward(craftType:String, feedRewardUrl:String) : void
      {
         this.m_craftPreorderRewardUrl = feedRewardUrl;
         var rewardItemName:String = Global.farmGameSettingsManager.getString("craftingSignUpItem_" + craftType);
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardItemName);
         Global.player.addGift(rewardItemName);
         Global.player.setSeenFlag("setFirstCraft");
         var message:String = ZLocUtils.t("Crafting","ChooseCraftRewardMessage");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_OK,this.onAcceptGiftBox,rewardItem.icon);
         UI.displayPopup(dialog);
      }
      
      private function onAcceptGiftBox(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayGiftBoxWindow();
            FarmStatsManager.count("crafting_cottages","bakery_lite","gnome_flow","click_check_gift");
         }
         else
         {
            FarmStatsManager.count("crafting_cottages","bakery_lite","gnome_flow","click_close");
         }
      }
      
      public function getAndResetPreorderRewardUrl() : String
      {
         var url:String = this.m_craftPreorderRewardUrl;
         this.m_craftPreorderRewardUrl = null;
         return url;
      }
      
      public function startCraftType(craftType:String) : void
      {
         if(Global.player.craftingState.craftingSkillState.getCraftTypeState(craftType) == null)
         {
            Global.player.craftingState.craftingSkillState.addCraftTypeState(new CraftTypeState(craftType));
         }
      }
      
      public function buyCraftTypeUpgrade(craftType:String, isRushUpgrade:Boolean) : Boolean
      {
         var craftLevelInfo:CraftLevel = null;
         var instances:Array = null;
         var building:CraftingCottageBuilding = null;
         var craftTypeState:CraftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(craftType);
         var canAfford:Boolean = false;
         if(craftTypeState != null)
         {
            craftLevelInfo = Global.craftConfigSettings.getCraftLevel(craftTypeState.level + 1);
            if(craftLevelInfo)
            {
               if(isRushUpgrade)
               {
                  if(Global.player.canBuyCash(craftLevelInfo.cashCost))
                  {
                     Global.player.cash -= craftLevelInfo.cashCost;
                     canAfford = true;
                  }
               }
               else if(Global.player.canBuy(craftLevelInfo.goldCost))
               {
                  Global.player.gold -= craftLevelInfo.goldCost;
                  canAfford = true;
               }
               if(canAfford)
               {
                  craftTypeState.incrementLevel();
                  instances = this.getPlacedCraftingCottages();
                  building = this.getCottageByCraft(craftType);
                  if(building)
                  {
                     Global.player.craftingState.craftingSkillState.grantDefaultRecipes();
                     TransactionManager.addTransaction(new TCraftBuyUpgrade(craftType,isRushUpgrade,function(tResult:Object):void
                     {
                        onCraftUpgraded(tResult,building);
                     }));
                  }
               }
            }
         }
         return canAfford;
      }
      
      private function onAddToCrewQueueTransactionComplete(result:Object, callback:Function) : void
      {
         callback(result);
      }
      
      public function getAddToCrewQueueRewardLink(itemCode:String, callback:Function) : void
      {
      }
      
      private function onGetAddToCrewQueueRewardLinkTransactionComplete(result:Object, callback:Function) : void
      {
         callback(result);
      }
      
      public function onCraftUpgraded(tResult:Object, cottageBuilding:CraftingCottageBuilding) : void
      {
         var localizationObj:Object = null;
         var feed:CraftingCottageFeed = null;
         if(tResult.rewardLink)
         {
            localizationObj = {
               "cottage":CraftingManager.getInstance().getCottageFriendlyNameByCraft(cottageBuilding.craftType),
               "level":getCraftLevelFriendlyName(cottageBuilding.craftLevel),
               "craftingStatusCottageName":CraftingManager.getCraftingStatusCottageNameLocString(cottageBuilding.craftLevel,cottageBuilding.craftType)
            };
            feed = new CraftingCottageFeed("CraftingCottage_cottage_upgraded",tResult.rewardLink,localizationObj);
            feed.setImage(cottageBuilding.getCurrentImageUrl());
            feed.startFeedFlow();
         }
      }
      
      private function canClaimFreeCottage() : Boolean
      {
         var levelValid:Boolean = Global.player.level >= Global.farmGameSettingsManager.getAttribute("craftingCottageStartLevel",25);
         var hasClaimedCottage:Boolean = Global.player.getSeenFlag("UnlockedCottage");
         var isAtHomeFarm:Boolean = Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME;
         return levelValid && !hasClaimedCottage && isAtHomeFarm;
      }
      
      public function setShowPlaceCottageReminderOnLoad() : void
      {
         this.m_showPlaceCottageReminderOnLoad = true;
      }
      
      public function showCottageReminderOnLoad() : void
      {
         var isAtHomeWorld:Boolean = Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME;
         if(isAtHomeWorld && !this.m_freeCottageWindowShown && this.getNumberOfPlacedCraftingCottages() == 0)
         {
            this.showCottageReminder("feed",false,true);
            this.m_freeCottageWindowShown = true;
         }
      }
      
      public function showCottageReminder(localizeSuffix:String, showChoosePrompt:Boolean, addPromptToQueue:Boolean) : void
      {
         var cottageItem:FarmItem = null;
         var message:String = null;
         var dialog:GenericPopup = null;
         var chooseMessage:String = null;
         var chooseIconUrl:String = null;
         var popup:GenericIconPopup = null;
         var cottagesInGiftBox:Array = this.getCottageItemNamesInGiftBox();
         var hasCottageGift:Boolean = cottagesInGiftBox.length > 0;
         if(hasCottageGift)
         {
            cottageItem = Global.farmGameSettingsManager.getFarmItemByName(cottagesInGiftBox[0]);
            if(cottageItem)
            {
               message = ZLocUtils.t("Crafting","PlaceCottageFromGift_" + localizeSuffix,{"item":ZLocUtils.tk_pk(cottageItem.friendlyName)});
               dialog = new GenericPopup(message,GenericPopup.TYPE_OK,this.onPlaceCottageFromGiftBox);
               dialog.setAcceptTextName("PlaceCottageButton");
               UI.displayPopup(dialog,addPromptToQueue);
               FarmStatsManager.count("crafting_cottage","adoption_prompts",localizeSuffix + "_source","place_from_giftbox_impression");
               this.m_craftingReminderSource = localizeSuffix;
            }
         }
         else if(this.canClaimFreeCottage())
         {
            if(showChoosePrompt)
            {
               chooseMessage = ZLocUtils.t("Crafting","ChooseCottageReminder_" + localizeSuffix);
               chooseIconUrl = Global.getAssetURL(Global.farmGameSettingsManager.getString("craftingChooseReminderIcon"));
               popup = new GenericIconPopup(chooseMessage,GenericPopup.TYPE_OK,this.onCloseChooseCottageReminder,chooseIconUrl);
               popup.setAcceptTextName("Choose");
               UI.displayPopup(popup,addPromptToQueue);
            }
            else
            {
               UI.displayPopup(new ChooseCottageWindow());
            }
            FarmStatsManager.count("crafting_cottage","adoption_prompts",localizeSuffix + "_source","choose_cottage_impression");
            this.m_craftingReminderSource = localizeSuffix;
         }
      }
      
      public function getCraftingBuildingIcon(craftType:String) : String
      {
         var result:String = "";
         var craftBuilding:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("crafting" + craftType);
         if(craftBuilding)
         {
            result = craftBuilding.icon;
         }
         else
         {
            result = Global.getAssetURL(Global.farmGameSettingsManager.getString("craftingWildcardGoodRewardIcon"));
         }
         return result;
      }
      
      private function onCloseChooseCottageReminder(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayPopup(new ChooseCottageWindow());
            if(this.m_craftingReminderSource != null)
            {
               FarmStatsManager.count("crafting_cottage","adoption_prompts",this.m_craftingReminderSource + "_source","choose_cottage_click_choose");
            }
         }
      }
      
      public function onPlaceCottageFromGiftBox(event:GenericPopupEvent) : void
      {
         var itemNames:Array = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            itemNames = this.getCottageItemNamesInGiftBox();
            if(itemNames.length > 0)
            {
               this.placeCottageFromGiftBox(itemNames[0]);
               if(this.m_craftingReminderSource != null)
               {
                  FarmStatsManager.count("crafting_cottage","adoption_prompts",this.m_craftingReminderSource + "_source","place_from_giftbox_click_place");
               }
            }
         }
      }
      
      public function claimFreeCottage(craftType:String, callback:Function = null) : void
      {
         var cottageLocalizationToken:LocalizationObjectToken = null;
         var t:TClaimFreeCottage = null;
         var cottage:FarmItem = this.getCraftCottage(craftType);
         if(cottage != null)
         {
            if(!Global.player.hasGiftBoxCapacity())
            {
               cottageLocalizationToken = ZLocUtils.tk_pk(cottage.friendlyName);
               UI.displayMessage(ZLocUtils.t("Crafting","ChooseCraftGiftBoxFull",{
                  "item":cottageLocalizationToken,
                  "item_same":cottageLocalizationToken
               }));
               FarmStatsManager.count("crafting_cottage","onboarding","giftboxfull");
            }
            else
            {
               Global.player.addGift(cottage.name);
               this.placeCottageFromGiftBox(cottage.name,true);
               t = new TClaimFreeCottage(cottage.code,function(result:Object):void
               {
                  onFreeCottageClaimed(result,craftType);
                  if(callback != null)
                  {
                     callback();
                  }
               });
               TransactionManager.addTransaction(t);
               Global.player.craftingState.craftingSkillState.grantDefaultRecipes();
               if(this.m_craftingReminderSource != null)
               {
                  FarmStatsManager.count("crafting_cottage","adoption_prompts",this.m_craftingReminderSource + "_source","choose_cottage_click_place");
               }
            }
         }
      }
      
      private function placeCottageFromGiftBox(itemName:String, reminder:Boolean = false) : void
      {
         var toasterTitle:String = null;
         var toasterMessage:String = null;
         Global.world.addGameMode(new GMBuild(itemName,true,0,false));
         var cottageItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(cottageItem)
         {
            if(reminder)
            {
               Global.player.setItemFlag("ForcePlace_Reminder",cottageItem.code);
            }
            toasterTitle = ZLocUtils.t("Crafting","PlacementToasterTitle");
            toasterMessage = ZLocUtils.t("Crafting","PlaceCottageToasterMessage");
            ToasterManager.getInstance().add(new IconTitleToasterWindow(toasterTitle,toasterMessage,cottageItem.icon,"assets/dialogs/FV_PlacementMode_BannerAd.swf",0.5,new Point(14,11)));
         }
      }
      
      private function onFreeCottageClaimed(result:Object, craftType:String) : void
      {
         FarmStatsManager.count("crafting_cottage","onboarding","place",craftType);
      }
      
      public function grantOnboardingGoodies(craftType:String) : void
      {
         var beginOOS_itemsStr:String = null;
         var recipe:RecipeItem = Global.craftConfigSettings.getBonusRecipe(craftType);
         for(var i:int = 0; i < recipe.ingredients.length; i++)
         {
            this.addItemToInventory(recipe.ingredients[i].itemCode,recipe.ingredients[i].quantityRequired);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
            {
               beginOOS_itemsStr = "item_" + recipe.ingredients[i].itemCode + ":" + recipe.ingredients[i].quantityRequired + ",";
               FarmStatsManager.count("beginOOS","client","add_grantOnboardingGoodies",beginOOS_itemsStr);
            }
         }
         CraftingRecipeQueueManager.getInstanceByCraftType(recipe.craft).beginRecipe(recipe,true);
      }
      
      public function getCraftCottage(craftType:String) : FarmItem
      {
         var craftCottage:FarmItem = null;
         var cottages:Array = Global.farmGameSettingsManager.getItemsByClassArray("CraftingCottageBuilding");
         for each(craftCottage in cottages)
         {
            if(craftCottage.craftType == craftType)
            {
               break;
            }
         }
         return craftCottage;
      }
      
      public function onBeginSetCraftedGoodPrice(craftingCottageBuilding:CraftingCottageBuilding, productItemCode:String, newPrice:Number, oldPrice:Number, callback:Function = null) : void
      {
         var callbackClosure:Function = function(responseCode:int):void
         {
            onEndSetCraftedGoodPrice(responseCode,craftingCottageBuilding,productItemCode,newPrice,oldPrice,callback);
         };
         var t:TSetCraftedGoodPrice = new TSetCraftedGoodPrice(craftingCottageBuilding.getId(),productItemCode,newPrice,callbackClosure);
         TransactionManager.addTransaction(t,oldPrice > 0);
      }
      
      public function onEndSetCraftedGoodPrice(responseCode:int, craftingCottageBuilding:CraftingCottageBuilding, productItemCode:String, newPrice:Number, oldPrice:Number, callback:Function) : void
      {
         var product:FarmItem = null;
         var message:String = null;
         var popup:GenericPopup = null;
         if(responseCode != TSetCraftedGoodPrice.PRICE_SET_OK)
         {
            craftingCottageBuilding.updatePriceForCompletedGood(productItemCode,oldPrice,true);
            product = Global.farmGameSettingsManager.getFarmItemByCode(productItemCode);
            message = ZLocUtils.t("Crafting","CraftingCottage_updatePriceErrorGeneric",{"item":ZLocUtils.tk_pk(product.friendlyName)});
            popup = new GenericPopup(message,GenericPopup.TYPE_OK);
            UI.displayPopup(popup,false);
         }
         if(callback != null)
         {
            callback(responseCode);
         }
      }
      
      public function getNumberOfPlacedCraftingCottages() : int
      {
         return this.getPlacedCraftingCottages().length;
      }
      
      public function getPlacedCraftingCottages() : Array
      {
         return Global.world.getObjectsByClass(CraftingCottageBuilding);
      }
      
      public function hasPlacedCraftingCottage(craftType:String) : Boolean
      {
         var cottage:CraftingCottageBuilding = null;
         var result:Boolean = false;
         var craftingCottages:Array = this.getPlacedCraftingCottages();
         for each(cottage in craftingCottages)
         {
            if(cottage.craftType == craftType)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function getCottagesInGiftBox() : int
      {
         return this.getCottageItemNamesInGiftBox().length;
      }
      
      public function getCottageItemNamesInGiftBox() : Array
      {
         var giftItem:StorageItem = null;
         var itemNames:Array = new Array();
         var gifts:Array = Global.player.getGifts();
         for each(giftItem in gifts)
         {
            if(giftItem.item.className == "CraftingCottageBuilding")
            {
               itemNames.push(giftItem.item.name);
            }
         }
         return itemNames;
      }
      
      public function hasCottageInGiftBox(craftType:String) : Boolean
      {
         var cottageName:String = null;
         var hasRequiredCottage:Boolean = false;
         var cottagesInGiftBox:Array = this.getCottageItemNamesInGiftBox();
         var hasCottageGift:Boolean = cottagesInGiftBox.length > 0;
         if(hasCottageGift)
         {
            for each(cottageName in cottagesInGiftBox)
            {
               if(craftType == cottageName)
               {
                  hasRequiredCottage = true;
                  break;
               }
            }
         }
         return hasRequiredCottage;
      }
      
      public function updateCraftingCottageStates() : void
      {
         var obj:Object = null;
         var building:CraftingCottageBuilding = null;
         var task:CraftingCottageRecipeReadyTask = null;
         var instances:Array = this.getPlacedCraftingCottages();
         for each(obj in instances)
         {
            building = obj as CraftingCottageBuilding;
            if(building != null)
            {
               building.reloadImage();
            }
         }
         if(this.hasCraftingCottageWithReadyRecipe())
         {
            task = new CraftingCottageRecipeReadyTask();
            task.submit();
         }
      }
      
      public function isRecipeAvailable(recipeId:String) : Boolean
      {
         return Global.craftConfigSettings.getRecipeById(recipeId) != null;
      }
      
      public function isBushelExpired(itemCode:String) : Boolean
      {
         var isExpired:Boolean = false;
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(bushelItem)
         {
            isExpired = !FarmGameUtil.checkDateGate(bushelItem.getLimitedStartDate(),bushelItem.getLimitedEndDate());
         }
         return isExpired;
      }
      
      public function exchangeLimitedBushels(itemCode:String, callback:Function) : void
      {
         var tExchange:TExchangeBushels = new TExchangeBushels(itemCode,callback);
         TransactionManager.addTransaction(tExchange,true);
      }
      
      public function isRecipeLocked(recipeId:String) : int
      {
         var craftType:String = null;
         var craftTypeState:CraftTypeState = null;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var result:int = 0;
         var recipeState:RecipeState = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeId);
         if(recipeItem == null)
         {
            result = CraftingConstants.RECIPE_LOCKED_UNAVAILABLE;
         }
         if(recipeItem != null)
         {
            craftType = recipeItem.craft;
            craftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(craftType);
            if(craftTypeState == null || craftTypeState.level == 0 || recipeItem.skillLevelRequired > craftTypeState.level)
            {
               result = CraftingConstants.RECIPE_LOCKED_LOW_SKILL;
            }
            else if(recipeItem.comingSoon)
            {
               result = CraftingConstants.RECIPE_LOCKED_COMING_SOON;
            }
            else if(recipeState == null || !recipeState.isUnlocked)
            {
               if(this.isRecipeBuyable(recipeId))
               {
                  result = CraftingConstants.RECIPE_LOCKED_BUYABLE;
               }
               else
               {
                  result = CraftingConstants.RECIPE_LOCKED_UNKNOWN;
               }
            }
         }
         return result;
      }
      
      public function getNewLimitedRecipes(craftType:String) : Array
      {
         var recipe:RecipeItem = null;
         var result:Array = new Array();
         var seenFlag:String = "";
         var allRecipes:Array = Global.craftConfigSettings.getAllRecipes(craftType);
         for each(recipe in allRecipes)
         {
            seenFlag = CraftingConstants.NEW_LIMITED_RECIPE_SEEN_FLAG_PREFIX + recipe.id;
            if(recipe.isLimited && recipe.isLimitedValid() && !recipe.isExpiring(this.EXPIRING_RECIPE_BUFFER_MS) && !Global.player.getSeenFlag(seenFlag))
            {
               result.push(recipe);
            }
         }
         return result;
      }
      
      public function getSpecialization(craftType:String, specializationId:String) : CraftSpecialization
      {
         var result:CraftSpecialization = null;
         var craftTypeState:CraftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(craftType);
         if(craftTypeState)
         {
            result = craftTypeState.getSpecialization(specializationId);
         }
         return result;
      }
      
      public function getExpiringRecipes(craftType:String) : Array
      {
         var recipe:RecipeItem = null;
         var result:Array = new Array();
         var seenFlag:String = "";
         var allRecipes:Array = Global.craftConfigSettings.getAllRecipes(craftType);
         for each(recipe in allRecipes)
         {
            seenFlag = CraftingConstants.EXPIRING_RECIPE_SEEN_FLAG_PREFIX + recipe.id;
            if(recipe.isLimited && recipe.isExpiring(this.EXPIRING_RECIPE_BUFFER_MS) && !Global.player.getSeenFlag(seenFlag))
            {
               result.push(recipe);
            }
         }
         return result;
      }
      
      public function getExpiredRecipes(craftType:String) : Array
      {
         var recipe:RecipeItem = null;
         var result:Array = new Array();
         var seenFlag:String = "";
         var allRecipes:Array = Global.craftConfigSettings.getAllRecipes(craftType);
         for each(recipe in allRecipes)
         {
            seenFlag = CraftingConstants.EXCHANGE_RECIPE_SEEN_FLAG_PREFIX + recipe.id;
            if(recipe.isLimited && !recipe.isLimitedValid() && !Global.player.getSeenFlag(seenFlag))
            {
               result.push(recipe);
            }
         }
         return result;
      }
      
      public function getRecipeLockedReason(recipeId:String, reasonCode:int) : String
      {
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var reason:String = null;
         switch(reasonCode)
         {
            case 0:
               reason = "Error : Should not be locked";
               break;
            case CraftingConstants.RECIPE_LOCKED_UNAVAILABLE:
               reason = ZLocUtils.t("Crafting","CraftingCottage_recipeLockedUnavailable");
               break;
            case CraftingConstants.RECIPE_LOCKED_LOW_SKILL:
               reason = ZLocUtils.t("Crafting","CraftingCottage_recipeLockedLowSkill" + recipeItem.skillLevelRequired);
               break;
            case CraftingConstants.RECIPE_LOCKED_BUYABLE:
               reason = ZLocUtils.t("Crafting","CraftingCottage_recipeLockedBuyable");
               break;
            case CraftingConstants.RECIPE_LOCKED_COMING_SOON:
               reason = ZLocUtils.t("Crafting","CraftingCottage_recipeLockedComingSoon");
               break;
            default:
               reason = ZLocUtils.t("Crafting","CraftingCottage_recipeLockedUnknown");
         }
         return reason;
      }
      
      public function isRecipeBuyable(recipeId:String) : Boolean
      {
         return false;
      }
      
      public function claimRecipeIngredients(recipeItem:RecipeItem) : void
      {
         var beginOOS_itemsStr:String = null;
         var ingredient:Object = null;
         var beforeQty:int = 0;
         var afterQty:int = 0;
         var ingredients:Array = null;
         if(CraftingManager.getInstance().shouldUseSmartCrafting(recipeItem.craft))
         {
            ingredients = recipeItem.smartModifiedRequirements;
         }
         else
         {
            ingredients = recipeItem.ingredients;
         }
         for each(ingredient in ingredients)
         {
            beforeQty = CraftingManager.getInstance().getBushelQuantityInInventory(ingredient.itemCode);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
            {
               beginOOS_itemsStr = "item_" + ingredient.itemCode + ":" + "need_" + ingredient.quantityRequired + ":have_" + beforeQty;
               FarmStatsManager.count("beginOOS","client","claimRecipe",beginOOS_itemsStr);
            }
            if(!this.deductItemFromCraftingInventory(ingredient.itemCode,ingredient.quantityRequired))
            {
               throw new Error("CraftingManager::claimRecipeIngredients assert failed - item: " + ingredient.itemCode + " qty:" + ingredient.quantityRequired + " could not be claimed");
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS2) > 0)
            {
               beginOOS_itemsStr = "item_" + ingredient.itemCode + ":" + ingredient.quantityRequired;
               FarmStatsManager.count("beginOOS","client","deduct_claimRecipeIng",beginOOS_itemsStr);
            }
            afterQty = CraftingManager.getInstance().getBushelQuantityInInventory(ingredient.itemCode);
         }
      }
      
      public function craftInstantItem(callback:Function, recipeItem:RecipeItem, trackMadeRecipe:Boolean) : void
      {
         var callbackClosure:Function;
         this.claimRecipeIngredients(recipeItem);
         callbackClosure = function(tResult:Object):void
         {
            onCraftInstantItem(callback,tResult);
         };
         TransactionManager.addTransaction(new TCraftInstantRecipe(recipeItem.id,trackMadeRecipe,callbackClosure));
      }
      
      private function onCraftInstantItem(callback:Function, result:Object) : void
      {
         var isInDataSourceExperiment:Boolean = false;
         var harvestableItem:FarmItem = null;
         var giftsToAdd:int = 0;
         var mostValuableBushel:FarmItem = null;
         var harvestSource:FarmItem = null;
         var buildingName:String = null;
         var dialogBundle:String = null;
         var localizedCopy:String = null;
         var callbackClosure:Function = null;
         var labConfig:XML = null;
         var callOutSwf:String = null;
         var popUp:GenericObjectPreviewPopup = null;
         var code:String = "";
         if(result)
         {
            isInDataSourceExperiment = FarmGameSettingsManager.isInDataSourceExperiment();
            harvestableItem = null;
            if(result.hasOwnProperty("productItemCode") && result.hasOwnProperty("numGiftProducts"))
            {
               code = result.productItemCode;
               giftsToAdd = int(result.numGiftProducts);
               if(isInDataSourceExperiment)
               {
                  harvestableItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
                  Global.player.addGift(harvestableItem.name,"0",giftsToAdd);
               }
               else
               {
                  harvestableItem = new FarmItem(Global.farmGameSettingsManager.getItemXMLByCode(code));
                  Global.player.addGift(harvestableItem.name,"0",giftsToAdd);
               }
            }
            if(result.hasOwnProperty("bushelItemCode"))
            {
               mostValuableBushel = Global.farmGameSettingsManager.getFarmItemByCode(result.bushelItemCode);
               harvestSource = Global.farmGameSettingsManager.getFarmItemByCode(mostValuableBushel.crop);
               if(isInDataSourceExperiment)
               {
                  buildingName = harvestSource ? harvestSource.getStringFromDataSource("buildingName") : "";
               }
               else
               {
                  buildingName = harvestSource ? harvestSource.xml.@buildingName : "";
               }
               dialogBundle = buildingName + "CraftingComplete";
               localizedCopy = ZLocUtils.t("Dialogs",dialogBundle,{
                  "item":ZLocUtils.tk_pk(harvestableItem.friendlyName),
                  "bushel":ZLocUtils.tk_pk(mostValuableBushel.friendlyName)
               });
               callbackClosure = function(evt:GenericPopupEvent):void
               {
                  var suffix:String = null;
                  if(result.hasOwnProperty("feedRewardUrl") && evt.button == GenericPopup.ACCEPT)
                  {
                     suffix = "_craftsuccessbushel" + Utilities.getSuffixForFeedLocalization(ZLocUtils.tk_pk_asTitle(harvestableItem.friendlyName));
                     CraftingManager.getInstance().displayShareMarketStallFeed(mostValuableBushel,1,result.feedRewardUrl,buildingName + suffix,harvestableItem.icon,harvestableItem.friendlyName);
                  }
               };
               labConfig = LabBuildingManager.getInstance().getLabBuilding(buildingName);
               callOutSwf = Boolean(labConfig) && Boolean(labConfig[CraftingConstants.CALLOUT_SWF]) ? labConfig[CraftingConstants.CALLOUT_SWF] : null;
               if(isInDataSourceExperiment)
               {
                  if(!harvestableItem)
                  {
                     harvestableItem = Global.farmGameSettingsManager.getFarmItemByCode(result.productItemCode);
                  }
               }
               else
               {
                  harvestableItem = new HarvestableItem(Global.farmGameSettingsManager.getItemXMLByCode(result.productItemCode));
               }
               popUp = new GenericObjectPreviewPopup(harvestableItem,localizedCopy,GenericPopup.TYPE_SHARE,callbackClosure,callOutSwf);
               if(buildingName == "AnimalBreedingDragonLair")
               {
                  FarmStatsManager.count("animal_mastery",harvestableItem.subsubtype,harvestableItem.name,"zeroStar");
               }
               if(labConfig[CraftingConstants.CRAFT_COMPLETE_SOUND])
               {
                  SoundManager.playSound(CraftingConstants.CRAFT_COMPLETE_SOUND);
               }
               UI.displayPopup(popUp,false);
            }
         }
         callback(code,true);
      }
      
      public function beginRecipe(recipeItem:RecipeItem, callback:Function = null, source:String = "") : void
      {
         var t:TBeginRecipe;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
         {
            FarmStatsManager.count("beginOOS","client","beginRecipe",recipeItem.id.toString());
         }
         this.claimRecipeIngredients(recipeItem);
         CraftingRecipeQueueManager.getInstanceByCraftType(recipeItem.craft).beginRecipe(recipeItem);
         recipeItem.grantMakeReward(Global.player);
         t = new TBeginRecipe(recipeItem.id,recipeItem.ovenSlot,function(tResult:Object):void
         {
            onRecipeBegun(tResult);
            if(callback != null)
            {
               callback(tResult);
            }
         });
         DailyStatsManager.getInstance().incrementCounter(source == DailyStatsManager.SOURCE_CRAFT_SHOP ? DailyStatsManager.SOURCE_CRAFT_SHOP : DailyStatsManager.SOURCE_CRAFTING_COTTAGE,DailyStatsManager.ACTION_CRAFT,1);
         TransactionManager.addTransaction(t,true);
      }
      
      private function onRecipeBegun(tResult:Object) : void
      {
         if(tResult.hasOwnProperty("crewQueue"))
         {
            Global.player.craftingState.updateCrewHelpers(tResult.crewQueue);
         }
         CraftingRecipeQueueManager.getInstanceByCraftType(tResult.recipe.craft).onRecipeBegun(tResult);
      }
      
      public function handleRecipeBegunResult(tResult:Object, feedDoneCallback:Function = null) : Boolean
      {
         var masterySignItem:FarmItem = null;
         var recipeItem:RecipeItem = null;
         var recipeLevel:Number = NaN;
         var craftType:String = null;
         var localizationObj:Object = null;
         var crewRecipeId:String = null;
         var bundleName:String = null;
         var craftshopFeed:CraftshopFeed = null;
         var feed:CraftingCottageFeed = null;
         var postedFeed:Boolean = false;
         if(Global.player.masterySignEnabled() && tResult.hasOwnProperty("masterySign") && Boolean(tResult.masterySign))
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(tResult.masterySign));
            }
            else
            {
               masterySignItem = new FarmItem(Global.farmGameSettingsManager.getItemXMLByCode(tResult.masterySign));
               Global.player.addGift(masterySignItem.name);
            }
         }
         if(tResult.rewardLink)
         {
            postedFeed = true;
            recipeItem = RecipeItem.fromPhpObject(tResult);
            recipeLevel = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeItem.id).level;
            craftType = recipeItem.craft;
            if(Global.craftConfigSettings.getCraftVersion(craftType) >= CraftConfigSettings.CRAFT_VERSION_CRAFTSHOP)
            {
               crewRecipeId = "";
               if(tResult.hasOwnProperty("masterySign") && Boolean(tResult.masterySign))
               {
                  bundleName = "CraftingRecipeMastered";
               }
               else if(tResult.hasOwnProperty("isRecipeLevelUp") && Boolean(tResult.isRecipeLevelUp))
               {
                  bundleName = "CraftingRecipeLevelUp";
               }
               else
               {
                  bundleName = "CraftingStartRecipe";
                  crewRecipeId = recipeItem.id;
               }
               localizationObj = {
                  "cottageName":this.getCottageFriendlyNameByCraft(craftType),
                  "recipe":recipeItem.friendlyName + "_recipe",
                  "item":recipeItem.friendlyName,
                  "level":recipeLevel
               };
               craftshopFeed = new CraftshopFeed(bundleName,tResult.rewardLink,localizationObj,feedDoneCallback,crewRecipeId,recipeItem.image);
               craftshopFeed.setImage(recipeItem.image);
               craftshopFeed.startFeedFlow();
            }
            else
            {
               localizationObj = {
                  "item":recipeItem.friendlyName,
                  "level":recipeLevel,
                  "level_same":recipeLevel,
                  "item_same":recipeItem.friendlyName,
                  "cottageName":this.getCottageFriendlyNameByCraft(craftType)
               };
               feed = new CraftingCottageFeed("CraftingCottage_recipe_levelup",tResult.rewardLink,localizationObj);
               feed.setImage(recipeItem.image);
               feed.startFeedFlow();
            }
         }
         return postedFeed;
      }
      
      public function beginClaimFinishedRecipes(tCallback:Function = null, recipeId:String = null, fCallback:Function = null, ovenSlot:int = -1) : void
      {
         var callbackClosure:Function = function(tResult:Object):void
         {
            endFinishedRecipesClaimed(tResult,recipeId,tCallback,fCallback);
         };
         var t:TClaimFinishedRecipes = new TClaimFinishedRecipes(callbackClosure,recipeId,ovenSlot);
         TransactionManager.addTransaction(t,true);
      }
      
      private function endFinishedRecipesClaimed(result:Object, recipeId:String, tCallback:Function = null, fCallback:Function = null) : void
      {
         var recipeItem:RecipeItem = null;
         if(result)
         {
            recipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
            CraftingRecipeQueueManager.getInstanceByCraftType(recipeItem.craft).endFinishedRecipesClaimed(result,recipeId,tCallback,fCallback);
         }
      }
      
      public function handleFinishFeed(rewardRecipe:Object, postFeed:Boolean, fCallback:Function = null) : void
      {
         var recipeId:String = null;
         var recipeItem:RecipeItem = null;
         var craftType:String = null;
         var localizationObj:Object = null;
         var craftshopFeed:CraftshopFeed = null;
         var feed:CraftingCottageFeed = null;
         if(Boolean(rewardRecipe) && rewardRecipe.hasOwnProperty("recipeId"))
         {
            recipeId = rewardRecipe.recipeId;
            recipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
            craftType = recipeItem.craft;
            if(Global.craftConfigSettings.getCraftVersion(craftType) >= CraftConfigSettings.CRAFT_VERSION_CRAFTSHOP)
            {
               if(rewardRecipe.rewardLink)
               {
                  localizationObj = {
                     "cottageName":this.getCottageFriendlyNameByCraft(craftType),
                     "recipe":recipeItem.friendlyName + "_recipe",
                     "item":recipeItem.friendlyName,
                     "quantity":rewardRecipe.quantity,
                     "level":rewardRecipe.recipeLevel
                  };
                  craftshopFeed = new CraftshopFeed("CraftingFinishRecipe",rewardRecipe.rewardLink,localizationObj,fCallback,recipeId,recipeItem.image);
                  craftshopFeed.setImage(recipeItem.image);
                  craftshopFeed.startFeedFlow();
               }
               else if(fCallback != null)
               {
                  fCallback();
               }
            }
            else
            {
               feed = null;
               if(postFeed && !Global.player.getSeenSessionFlag("recipeFinishFeed"))
               {
                  Global.player.setSeenSessionFlag("recipeFinishFeed");
                  FarmStatsManager.count("crafting_cottage","finish_goods","click_finish_get_prompt");
                  localizationObj = {
                     "user":Global.player.firstName,
                     "item":recipeItem.friendlyName,
                     "level":rewardRecipe.recipeLevel,
                     "quantity":rewardRecipe.quantity,
                     "cottageName":CraftingManager.getInstance().getCottageFriendlyNameByCraft(craftType)
                  };
                  feed = new CraftingCottageFeed("CraftingCottage_goods_made",rewardRecipe.rewardLink,localizationObj,fCallback);
                  feed.setImage(recipeItem.image);
                  feed.startFeedFlow();
               }
               else
               {
                  FarmStatsManager.count("crafting_cottage","finish_goods","click_finish_no_prompt");
                  if(fCallback != null)
                  {
                     fCallback();
                  }
               }
            }
         }
      }
      
      public function beginBuyRecipeRush(recipeItem:RecipeItem, withCoins:Boolean, callback:Function = null, withTime:Boolean = false) : void
      {
         var callbackClosure:Function = function(tResult:Object):void
         {
            endRecipeRushedBuy(recipeItem,tResult,callback);
         };
         var t:TBuyRecipeRush = new TBuyRecipeRush(recipeItem,withCoins,callbackClosure,withTime);
         TransactionManager.addTransaction(t,true);
      }
      
      private function endRecipeRushedBuy(recipeItem:RecipeItem, result:Object, callback:Function = null) : void
      {
         recipeItem.onRushComplete();
         if(callback != null)
         {
            callback(result);
         }
      }
      
      public function beginCancelRecipe(recipeItem:RecipeItem, callback:Function = null) : void
      {
         var callbackClosure:Function = function(tResult:Object):void
         {
            endRecipeRushedBuy(recipeItem,tResult,callback);
         };
         var t:TCancelRecipe = new TCancelRecipe(recipeItem);
         TransactionManager.addTransaction(t);
      }
      
      private function endRecipeCancel(recipeItem:RecipeItem, result:Object, callback:Function = null) : void
      {
         var cottage:CraftingCottageBuilding = this.getCottageByRecipe(recipeItem.id);
         cottage.onRecipeCancel(recipeItem);
         if(callback != null)
         {
            callback(result);
         }
      }
      
      public function hasCraftingCottageWithReadyRecipe() : Boolean
      {
         var thisCottage:CraftingCottageBuilding = null;
         var result:Boolean = false;
         var cottages:Array = this.getPlacedCraftingCottages();
         for(var i:int = 0; i < cottages.length; i++)
         {
            thisCottage = cottages[i];
            if(thisCottage != null && thisCottage.readyRecipes.length > 0)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function beginBuyCraftedGood(itemCode:String, itemLevel:int, fromUserId:String, amountOffered:int) : void
      {
         var craftingInventoryCap:int;
         var purchasesToday:int;
         var maxDailyPurchases:int;
         var message:String = null;
         var popup:GenericPopup = null;
         var endBuyGoodClosure:Function = null;
         var marketRefreshClosure:Function = null;
         this.m_buyGoodsShare = false;
         this.m_buyGoodsResponse = null;
         craftingInventoryCap = Global.storageSettings.maxStorageCap(CraftingConstants.CRAFTED_GOOD_STORAGE_NAME);
         purchasesToday = Global.player.craftingState.shoppingState.getTotalDailyCraftingPurchases();
         maxDailyPurchases = Global.player.craftingState.shoppingState.maxCraftingPurchasesPerDay;
         if(purchasesToday < maxDailyPurchases)
         {
            if(Global.player.craftingState.totalCraftedGoods < craftingInventoryCap)
            {
               if(Global.player.canBuy(amountOffered,false))
               {
                  endBuyGoodClosure = function(buyResponse:Object):void
                  {
                     endBuyCraftedGood(buyResponse,itemCode,itemLevel,fromUserId,amountOffered);
                  };
                  marketRefreshClosure = function(buyResponse:Object):void
                  {
                     endMarketViewRefresh(buyResponse);
                  };
                  Global.player.gold -= amountOffered;
                  Global.player.craftingState.shoppingState.addCraftingBagsUsed(fromUserId,1);
                  MarketViewManager.getInstance().adjustAvailableGoodQuantity(fromUserId,itemCode,-1);
                  if(m_tBuyCraftedGood == null)
                  {
                     m_tBuyCraftedGood = new TBuyCraftedGood(marketRefreshClosure);
                  }
                  m_tBuyCraftedGood.queueBuyGood(itemCode,String(fromUserId),amountOffered,endBuyGoodClosure);
               }
               else
               {
                  UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_COINS,"impulseBuyMarket",0,Global.farmGameSettingsManager.getFarmItemByCode(itemCode).type);
               }
            }
            else
            {
               message = ZLocUtils.t("Crafting","BuyCraftedGood_InventoryFull");
               popup = new GenericPopup(message,GenericPopup.TYPE_OK);
               UI.displayPopup(popup,false);
            }
         }
         else
         {
            message = ZLocUtils.t("Crafting","BuyCraftedGood_DailyMaxReached",{"friendlyTime":this.getFriendlyTimeToMoreBags()});
            popup = new GenericPopup(message,GenericPopup.TYPE_OK);
            UI.displayPopup(popup,false);
         }
      }
      
      private function endBuyCraftedGood(buyResponse:Object, itemCode:String, itemLevel:int, fromUserId:String, amountOffered:int) : void
      {
         var recipeLevel:int = 0;
         var message:String = null;
         var popup:GenericPopup = null;
         var friend:Friend = null;
         var friendGender:String = null;
         if(buyResponse.hasOwnProperty("buyResponse"))
         {
            buyResponse = buyResponse.buyResponse;
         }
         var responseCode:int = int(buyResponse.code);
         var sellPrice:int = int(buyResponse.price);
         if(responseCode == TBuyCraftedGood.GOOD_PURCHASED_OK)
         {
            if(buyResponse.hasOwnProperty("recipeLevel"))
            {
               recipeLevel = int(buyResponse.recipeLevel);
               if(recipeLevel != itemLevel)
               {
                  itemLevel = recipeLevel;
               }
            }
            Global.player.craftingState.addCraftedItemToInventory(CraftedItem.createCraftedItem(itemCode,itemLevel,1));
            if(buyResponse.hasOwnProperty("rewardLink"))
            {
               this.m_buyGoodsResponse = buyResponse;
               this.m_buyGoodsFromUserId = fromUserId;
               if(this.m_buyGoodsShare)
               {
                  this.sendBuyGoodsReward();
               }
            }
         }
         else
         {
            this.m_buyGoodsResponse = null;
            Global.player.craftingState.shoppingState.addCraftingBagsUsed(fromUserId,-1);
            Global.player.gold += amountOffered;
            if(responseCode != TBuyCraftedGood.GOOD_INSUFFICIENT_QUANTITY)
            {
               MarketViewManager.getInstance().adjustAvailableGoodQuantity(fromUserId,itemCode,1);
            }
            friend = Global.friendManager.getFriendData(fromUserId);
            friendGender = Global.friendManager.getFriendGender(fromUserId);
            if(responseCode == TBuyCraftedGood.OFFER_OUT_OF_SYNC)
            {
               MarketViewManager.getInstance().adjustAvailableGoodPrice(fromUserId,itemCode,sellPrice);
               message = ZLocUtils.t("Crafting","BuyCraftedGood_PriceChange",{"friend":ZLocUtils.tn(friend.name,ZLocUtils.tg(friendGender))});
               popup = new GenericPopup(message,GenericPopup.TYPE_OK);
            }
            else if(responseCode == TBuyCraftedGood.PURCHASE_LIMIT_HIT_USER)
            {
               message = ZLocUtils.t("Crafting","BuyCraftedGood_LimitPerUser",{
                  "item":ZLocUtils.tk_pk(Global.farmGameSettingsManager.getFarmItemByCode(itemCode).friendlyName),
                  "friend":ZLocUtils.tn(friend.name,ZLocUtils.tg(friendGender))
               });
               popup = new GenericPopup(message,GenericPopup.TYPE_OK);
            }
            else
            {
               message = ZLocUtils.t("Crafting","BuyCraftedGood_Error",{
                  "item":ZLocUtils.tk_pk(Global.farmGameSettingsManager.getFarmItemByCode(itemCode).friendlyName),
                  "friend":ZLocUtils.tn(friend.name,ZLocUtils.tg(friendGender))
               });
               popup = new GenericPopup(message,GenericPopup.TYPE_OK);
            }
            UI.displayPopup(popup,false);
         }
      }
      
      public function endMarketViewRefresh(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.buyResponse))
         {
            if(result.buyResponse.hasOwnProperty("marketview"))
            {
               MarketViewManager.getInstance().updateViewFromResponse(result.buyResponse.marketview);
               CraftingUI.onMarketViewRefreshed();
            }
         }
      }
      
      public function sendBuyGoodsReward() : void
      {
         var recipeId:String = null;
         var recipeItem:RecipeItem = null;
         var localizationObj:Object = null;
         var feed:CraftingCottageFeed = null;
         this.m_buyGoodsShare = true;
         if(this.m_buyGoodsResponse)
         {
            recipeId = this.m_buyGoodsResponse.recipe;
            recipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
            localizationObj = {
               "cottageName":this.getCottageFriendlyNameByCraft(recipeItem.craft),
               "item":recipeItem.friendlyName
            };
            feed = new CraftingCottageFeed("CraftingCottage_shopped",this.m_buyGoodsResponse.rewardLink,localizationObj,null);
            feed.setImage(recipeItem.image);
            feed.publishFeedWithoutPrompt([this.m_buyGoodsFromUserId]);
         }
      }
      
      public function canPublishBushelRequestFeed() : Boolean
      {
         var shoppingState:ShoppingState = Global.player.craftingState.shoppingState;
         return shoppingState.lastGetBushelsRequestTS < GlobalEngine.serverTime / 1000 - Global.craftConfigSettings.getBushelRequestFeedLimitSeconds();
      }
      
      public function getAllCraftTypeBushelCodes(type:int) : Array
      {
         var bushel:FarmItem = null;
         var allBushels:Array = Global.farmGameSettingsManager.getFarmItemsArrayByType("bushel");
         var typeBushels:Array = new Array();
         for each(bushel in allBushels)
         {
            if(CraftingManager.getInstance().getCraftTypeofBushel(bushel.code) == type)
            {
               typeBushels.push(bushel);
            }
         }
         return typeBushels;
      }
      
      public function onNoBushelsAvailableShopping(bushelCode:String, craftType:String = null, onCloseCallback:Function = null, bushelIcon:String = null) : void
      {
         var onCanPublishFeedClose:Function = null;
         var bushelItem:FarmItem = null;
         var message:String = null;
         var prompt:GenericPopup = null;
         var canPublishFeed:Boolean = this.canPublishBushelRequestFeed();
         if(canPublishFeed)
         {
            onCanPublishFeedClose = function(evt:GenericPopupEvent):void
            {
               var f:Function = null;
               var t:TGetBushelRequestFeed = null;
               if(evt.button == GenericPopup.ACCEPT)
               {
                  Global.player.craftingState.shoppingState.lastGetBushelsRequestTS = GlobalEngine.serverTime / 1000;
                  f = function(response:Object, bushelItemCode:String, craftType:String):void
                  {
                     beginBushelRequestFeedFlow(response,bushelItemCode,craftType,onCloseCallback);
                  };
                  t = new TGetBushelRequestFeed(bushelCode,craftType,f);
                  TransactionManager.addTransaction(t,true);
               }
               else if(onCloseCallback != null)
               {
                  onCloseCallback();
               }
            };
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelCode);
            if(bushelItem)
            {
               message = ZLocUtils.localizeWithOverrideSuffix("Dialogs","AskForHelpWithBushels_prompt",{"items":ZLocUtils.tk_pk(bushelItem.friendlyName)},"_crafting" + craftType);
               prompt = null;
               if(bushelIcon != null)
               {
                  prompt = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,onCanPublishFeedClose,bushelIcon,false,false);
               }
               else
               {
                  prompt = new GenericPopup(message,GenericPopup.TYPE_SHARECANCEL,onCanPublishFeedClose);
               }
               prompt.setTrackerKey("feed_ask_for_bushels");
               UI.displayPopup(prompt,false,"craftingFeedPrompt");
               FarmStatsManager.count("Crafting","Feed","AskForHelpWithBushels","impressions");
            }
         }
         else
         {
            this.popCantAskForBushelsDialog(bushelCode,craftType,onCloseCallback);
         }
      }
      
      private function popCantAskForBushelsDialog(bushelCode:String, craftType:String, onCloseCallback:Function = null) : void
      {
         var message:String = null;
         var prompt:GenericPopup = null;
         CraftingStatsManager.recordAlreadyAskedForBushelsPopup();
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelCode);
         if(bushelItem)
         {
            message = ZLocUtils.localizeWithOverrideSuffix("Dialogs","AskForBushelsFriendReward_status",{"items":ZLocUtils.tk_pk(bushelItem.friendlyName)},"_crafting" + craftType);
            prompt = new GenericPopup(message,GenericPopup.TYPE_OK,onCloseCallback);
            UI.displayPopup(prompt,false);
         }
         else if(onCloseCallback != null)
         {
            onCloseCallback();
         }
      }
      
      private function beginBushelRequestFeedFlow(response:Object, bushelItemCode:String, craftType:String, onCloseCallback:Function = null) : void
      {
         var bushelItem:FarmItem = null;
         var askForBushelsBundle:String = null;
         var localizationObj:Object = null;
         var feed:CraftingCottageFeed = null;
         if(response.hasOwnProperty("resultUrl"))
         {
            CraftingStatsManager.recordAskForBushelsPopup();
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelItemCode);
            askForBushelsBundle = Global.craftConfigSettings.getAskForBushelsBundle(craftType);
            localizationObj = {
               "item":bushelItem.friendlyName,
               "cottageName":this.getCottageFriendlyNameByCraft(craftType),
               "goodName":bushelItem.friendlyName
            };
            feed = new CraftingCottageFeed(askForBushelsBundle,response["resultUrl"],localizationObj,onCloseCallback);
            if(Global.craftConfigSettings.getAskForHelpWithBushelsUseItemForFeedImage(craftType))
            {
               feed.setImage(bushelItem.iconRelativeUrl);
            }
            else
            {
               feed.setImage("assets/newsfeed/craftingcottage_bushelsrequest.png");
            }
            feed.publishFeedWithoutPrompt();
         }
         else
         {
            this.popCantAskForBushelsDialog(bushelItemCode,craftType,onCloseCallback);
            if(response.hasOwnProperty("cantPostReason"))
            {
               ErrorManager.addError("Failed to create get bushel reward:" + response["cantPostReason"]);
            }
            else
            {
               ErrorManager.addError("Failed to post get bushel reward for unknown reason");
            }
         }
      }
      
      public function playerIsInV2Experiment() : Boolean
      {
         var cottage:CraftingCottageBuilding = null;
         var cottages:Array = this.getPlacedCraftingCottages();
         var oldestFoundingDate:Date = new Date();
         for each(cottage in cottages)
         {
            if(cottage.foundingDate < oldestFoundingDate)
            {
               oldestFoundingDate = cottage.foundingDate;
            }
         }
         return oldestFoundingDate <= Global.craftConfigSettings.v2FeatureReleaseDate;
      }
      
      public function getMasteryCount() : int
      {
         var recipeItem:RecipeItem = null;
         var recipeState:RecipeState = null;
         var completedLevels:Number = NaN;
         var requiredLevels:Number = NaN;
         var result:int = 0;
         var recipeIds:Array = Global.craftConfigSettings.getAllRecipeIds();
         for(var recipeIdIndex:int = 0; recipeIdIndex < recipeIds.length; recipeIdIndex++)
         {
            if(recipeIds[recipeIdIndex])
            {
               recipeItem = Global.craftConfigSettings.getRecipeById(recipeIds[recipeIdIndex]);
               recipeState = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeIds[recipeIdIndex]);
               if(Boolean(recipeState) && Boolean(recipeItem))
               {
                  if(Global.craftConfigSettings.getCraftVersion(recipeItem.craft) >= CraftConfigSettings.CRAFT_VERSION_CRAFTSHOP)
                  {
                     completedLevels = recipeState.getCompletedLevel();
                     requiredLevels = Global.craftConfigSettings.getMaxRecipeLevel(recipeIds[recipeIdIndex]);
                     if(requiredLevels <= completedLevels)
                     {
                        result++;
                     }
                  }
                  else if(recipeItem.getMasteryLevelForRecipeLevel(recipeState.level) > 0)
                  {
                     result++;
                  }
               }
            }
         }
         return result;
      }
      
      public function isIngredientGetByFeed(ingredientConfig:Object) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(ingredientConfig) && Boolean(ingredientConfig["getByFeed"]))
         {
            result = true;
         }
         return result;
      }
      
      public function getTimeUntilCanPublishGetByFeedIngredient(recipe:RecipeItem, ingredientConfig:Object) : Number
      {
         var featureFrequency:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Number = 0;
         var featureKey:String = "askForRecipeIngredient_" + recipe.id + "_" + ingredientConfig[RecipeItem.ITEM_CODE];
         var lastShown:Number = Global.player.getFeatureLastShown(featureKey);
         if(lastShown > 0)
         {
            featureFrequency = Global.craftConfigSettings.getRecipeIngredientRequestFeedLimitSeconds();
            timeLeft = lastShown + featureFrequency - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = Math.max(timeLeft,0);
            result = Math.min(timeLeft,featureFrequency);
         }
         return result;
      }
      
      public function canPublishGetByFeedIngredient(recipe:RecipeItem, ingredientConfig:Object) : Boolean
      {
         return this.getTimeUntilCanPublishGetByFeedIngredient(recipe,ingredientConfig) <= 0;
      }
      
      public function startGetByFeedIngredientFlow(recipe:RecipeItem, ingredientConfig:Object, onCloseCallback:Function = null) : void
      {
         var f:Function = null;
         if(this.canPublishGetByFeedIngredient(recipe,ingredientConfig))
         {
            f = function(response:Object):void
            {
               onAskForRecipeIngredientResponse(response,recipe,ingredientConfig,onCloseCallback);
            };
            TransactionManager.addTransaction(new TGenericTransactionWithFeed("CraftingService","onAskForRecipeIngredient",f,[recipe.id,ingredientConfig[RecipeItem.ITEM_CODE]]));
         }
         else
         {
            this.popCantAskForBushelsDialog(ingredientConfig[RecipeItem.ITEM_CODE],recipe.craft,onCloseCallback);
         }
      }
      
      private function onAskForRecipeIngredientResponse(response:Object, recipe:RecipeItem, ingredientConfig:Object, onCloseCallback:Function = null) : void
      {
         if(onCloseCallback != null)
         {
            onCloseCallback();
         }
      }
      
      public function showCraftingWindowForRecipe(recipeId:String) : Boolean
      {
         var buildings:Array = null;
         var dialog:CraftshopWindow = null;
         var cottage:CraftingCottageBuilding = null;
         var result:Boolean = false;
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         if(recipe.craft == CraftingConstants.CRAFTSHOP_SKILL)
         {
            buildings = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopBuildable());
            if(buildings.length > 0)
            {
               (buildings[0] as ConstructionBuilding).displayStorageDialog();
            }
            else
            {
               buildings = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
               if(buildings.length > 0)
               {
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MINIRECIPE_WINDOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
                  {
                     dialog = new CraftshopWindow(buildings[0],"craftingworkshopbuilding",recipeId);
                  }
                  else
                  {
                     dialog = new CraftshopWindow(buildings[0],"craftingworkshopbuilding");
                  }
                  UI.displayPopup(dialog,false,"CraftshopWindow",true);
                  result = true;
               }
            }
         }
         else
         {
            cottage = this.getCottageByRecipe(recipeId);
            if(cottage != null)
            {
               CraftingUI.displayCraftingMainWindow(cottage);
               result = true;
            }
         }
         return result;
      }
      
      public function openCraftingUiForRecipe(recipeId:String, craftingBuildingName:String = "") : void
      {
         var partiallyBuiltShops:Array = null;
         var completedShops:Array = null;
         var cottage:CraftingCottageBuilding = null;
         var cottageItemName:String = null;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_REPLACE_RECIPE_ID_PART_EMERALDWOOD);
         if(recipeId == ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"EmeraldWoodRecipeId") && variant == Experiments.VARIANT_FLASH_REPLACE_RECIPE_ID_PART_EMERALDWOOD)
         {
            recipeId = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"EmeraldLogRecipeId");
         }
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         if(recipe != null)
         {
            if(recipe.craft == CraftingConstants.CRAFTSHOP_SKILL)
            {
               partiallyBuiltShops = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopBuildable());
               completedShops = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
               if(partiallyBuiltShops.length > 0 || completedShops.length > 0)
               {
                  this.showCraftingWindowForRecipe(recipeId);
               }
               else
               {
                  surfaceNewCraftShop(craftingBuildingName);
               }
            }
            else
            {
               cottage = this.getCottageByRecipe(recipeId);
               if(cottage)
               {
                  this.showCraftingWindowForRecipe(recipeId);
               }
               else
               {
                  cottageItemName = Global.craftConfigSettings.getCottageItemNameForSkill(recipe.craft);
                  if(cottageItemName)
                  {
                     FeatureBuildingSurfacingManager.surfaceFeatureBuilding(Global.farmGameSettingsManager.getFarmItemByName(cottageItemName),true);
                  }
               }
            }
         }
      }
      
      public function openCraftshopWindow(buildingName:String, currencyName:String = null, callerWindow:FarmWindow = null, selectTab:String = "part", finishRecipeCallback:Function = null) : void
      {
         var dialog:DisplayObject = null;
         var partiallyBuiltShops:Array = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopBuildable());
         var completedShops:Array = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
         if(partiallyBuiltShops.length > 0 || completedShops.length > 0)
         {
            dialog = new CraftshopWindow(completedShops[0],"craftingworkshopbuilding",null,currencyName.toLowerCase(),selectTab,finishRecipeCallback);
            UI.displayPopup(dialog,false,"CraftshopWindow",true);
         }
         else
         {
            if(callerWindow)
            {
               callerWindow.close();
            }
            surfaceNewCraftShop(buildingName);
         }
      }
      
      private function getModifiedInventoryForSmartCrafting(itemCode:String, quantityRequired:int, craftType:String) : int
      {
         var multiplier:Number = NaN;
         var quantityDifference:int = 0;
         var inventoryQuantity:int = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
         var smartSystemConfig:SmartSystemData = CraftingManager.getInstance().getSmartSystemConfigByType(craftType);
         var smartSystemHelp:int = 0;
         if(smartSystemConfig)
         {
            multiplier = smartSystemConfig.multiplier;
            smartSystemHelp = Math.floor(multiplier * quantityRequired);
            quantityDifference = 0;
            if(smartSystemHelp < quantityRequired && smartSystemHelp > 0)
            {
               quantityDifference = quantityRequired - inventoryQuantity;
               if(quantityDifference <= 0)
               {
                  smartSystemHelp = 0;
               }
               else if(smartSystemHelp > quantityDifference)
               {
                  smartSystemHelp = quantityDifference;
               }
            }
         }
         return inventoryQuantity + smartSystemHelp;
      }
      
      public function getSmartSystemConfigByType(craftType:String) : SmartSystemData
      {
         var smartSystemConfig:SmartSystemData = null;
         var tuningTableName:String = Global.craftConfigSettings.getSmartSystemTuningTable(craftType);
         if(tuningTableName == this.SMART_CRAFTING_CRAFT_SHOP_TUNING_TABLE)
         {
            smartSystemConfig = Global.player.getSmartSystemCraftShopConfig();
         }
         else if(tuningTableName == this.SMART_CRAFTING_CRAFTING_COTTAGE_TUNING_TABLE)
         {
            smartSystemConfig = Global.player.getSmartSystemCraftingCottageConfig();
         }
         return smartSystemConfig;
      }
      
      public function shouldUseSmartCrafting(craftType:String) : Boolean
      {
         var hasTuningTable:Boolean = Global.craftConfigSettings.getSmartSystemTuningTable(craftType) != "";
         return this.isSmartCraftingEnabled() && hasTuningTable;
      }
      
      public function isSmartCraftingEnabled() : Boolean
      {
         var result:Boolean = false;
         if(Global.flashHotParams.hasOwnProperty("SMART_CRAFTING_ENABLED") && Global.flashHotParams["SMART_CRAFTING_ENABLED"] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function getInventoryCountHelper(itemCode:String, quantityRequired:int, craftType:String) : int
      {
         var numIngredients:int = 0;
         if(this.shouldUseSmartCrafting(craftType))
         {
            numIngredients = this.getModifiedInventoryForSmartCrafting(itemCode,quantityRequired,craftType);
         }
         else
         {
            numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
         }
         return numIngredients;
      }
   }
}

