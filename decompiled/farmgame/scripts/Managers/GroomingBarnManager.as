package Managers
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGenericTransaction;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import flash.events.Event;
   
   public class GroomingBarnManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:GroomingBarnManager = null;
      
      protected var m_recipeId:String;
      
      private var m_feedPostPending:Boolean;
      
      private var m_askCallback:Function;
      
      private var m_isAskUnlocked:Boolean = true;
      
      public const WINDOW_NAME:String = "groomingBarn";
      
      public const FEED_ITEM_NAME:String = "currybrush";
      
      private const BUILDING_NAME:String = "barngrooming";
      
      private const SERVICE_NAME:String = "GroomingBarnService";
      
      private const SERVICE_FUNCTION:String = "postFeed";
      
      private const DEFAULT_THROTTLE:String = "AskGroomingBrushFeed";
      
      private const DEFAULT_THROTTLE_TIME:int = 21600;
      
      public function GroomingBarnManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            this.loadConfig();
            return;
         }
         throw new Error("Error: Instantiation failed: Use GroomingBarnManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : GroomingBarnManager
      {
         if(m_instance == null)
         {
            m_instance = new GroomingBarnManager();
         }
         return m_instance;
      }
      
      private function loadConfig() : void
      {
         var recipe:RecipeItem = null;
         var growItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.FEED_ITEM_NAME);
         if(growItem)
         {
            recipe = Global.craftConfigSettings.getRecipeByProductItemCode(growItem.code);
         }
         if(Boolean(recipe) && Boolean(recipe.id))
         {
            this.m_recipeId = recipe.id;
         }
      }
      
      public function buy(item:FarmItem, currency:String) : void
      {
         if(Boolean(item) && Boolean(currency))
         {
            Global.player.buyFarmItem(item,currency,1);
         }
      }
      
      public function openGroomingWindow() : void
      {
         var buildingArray:Array = Global.world.getObjectsByName(this.BUILDING_NAME);
         if(buildingArray.length > 0)
         {
            (buildingArray[0] as FeatureBuilding).displayStorageDialog();
         }
      }
      
      public function canPostFeed() : Boolean
      {
         return this.getTimeUntilPostFeedEnabled() <= 0 && this.m_isAskUnlocked;
      }
      
      public function getTimeUntilPostFeedEnabled() : int
      {
         var result:int = this.DEFAULT_THROTTLE_TIME;
         var throttleName:String = Global.farmGameSettingsManager.getString(this.WINDOW_NAME + "AskTimeThrottleName",this.DEFAULT_THROTTLE);
         var throttleTime:int = Global.farmGameSettingsManager.getInt(this.WINDOW_NAME + "AskTimeThrottleTime",this.DEFAULT_THROTTLE_TIME);
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(throttleName);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function postGeneralFeed(callback:Function = null) : void
      {
         this.m_feedPostPending = true;
         this.m_isAskUnlocked = false;
         this.m_askCallback = callback;
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,this.SERVICE_FUNCTION,this.onFeedPostComplete),true);
      }
      
      public function getBrushCountText() : String
      {
         var groomingBrush:String = this.FEED_ITEM_NAME;
         var groomingBrushNumber:int = Global.player.getGiftCountForItem(groomingBrush);
         return groomingBrushNumber.toString();
      }
      
      private function onFeedPostComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,this.handleFeedPostReturn);
         }
      }
      
      private function handleFeedPostReturn(success:Boolean) : void
      {
         if(success)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(Global.farmGameSettingsManager.getString(this.WINDOW_NAME + "AskTimeThrottleName",this.DEFAULT_THROTTLE)),true);
            Global.player.setFeatureLastShown(Global.farmGameSettingsManager.getString(this.WINDOW_NAME + "AskTimeThrottleName",this.DEFAULT_THROTTLE),GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            FarmStatsManager.count("Feed","feed","yearlings","ask_grooming_brushes");
            this.m_feedPostPending = false;
            this.m_isAskUnlocked = false;
            if(this.m_askCallback != null)
            {
               this.m_askCallback(true);
            }
         }
         else
         {
            this.m_isAskUnlocked = true;
            if(this.m_askCallback != null)
            {
               this.m_askCallback(false);
            }
         }
      }
      
      public function showCraftingWindowWithItem() : void
      {
         var craftShop:String;
         var craftshopOpened:Boolean;
         var prompt:GenericXMLDialog = null;
         FarmStatsManager.count("craftshop","click","craft","grooming_brush");
         craftShop = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         craftshopOpened = false;
         if(this.m_recipeId)
         {
            if(CraftingManager.getInstance().showCraftingWindowForRecipe(this.m_recipeId))
            {
               craftshopOpened = true;
            }
         }
         if(!craftshopOpened)
         {
            prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName("craftingworkshop_finished","icon",false),100,100,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Message"),null,true,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Button"),function(event:Event):void
            {
               Global.world.enterForcePlaceMode("craftingworkshop_finished",true,0,false,false,{"suppressGiftRepop":true});
            });
            UI.displayPopup(prompt,true,"",true);
         }
      }
   }
}

