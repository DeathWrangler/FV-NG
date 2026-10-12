package Managers
{
   import Classes.StencilDecoration;
   import Classes.ZItem.FarmItem;
   import Classes.feed.StencilPurchaseFeed;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Windows.StencilRewardWindow;
   import Widgets.Windows.StencilWindow;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class StencilManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "stencil";
      
      private static const FEATURE_OPTIONS_OWNED_STENCILS:String = "ownedStencils";
      
      private const ASSET_MAIN:String = "main";
      
      private const ASSET_REWARD_DIALOG:String = "reward";
      
      private const DIALOG_SUFFIX_TUTORIAL_VIDEO:String = "tutorial_video";
      
      private const ASK_FEED_FREQUENCY_KEY:String = "bragFrequency";
      
      private const STATS_BUY:String = "buy_totem";
      
      private const STATS_USE:String = "use_totem";
      
      private const STATS_PLACE:String = "place_totem";
      
      public var mainWindow:StencilWindow;
      
      public var rewardWindow:StencilRewardWindow;
      
      private var m_askFeedFrequency:int = 21600;
      
      private var m_stencils:Array = new Array();
      
      private var m_lookbookImages:Array = new Array();
      
      public function StencilManager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.m_askFeedFrequency = int(this.featureConfig.feed.@throttleTime);
         this.loadStencils(this.featureConfig.items.children());
         this.loadLookbookImages(this.featureConfig.images.children());
         this.updateNewTags();
         this.sortStencils();
      }
      
      public static function instance(featureName:String = "stencil") : StencilManager
      {
         var instance:StencilManager = BaseFeatureManager.getInstanceOfClass(featureName,StencilManager) as StencilManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      public function get stencils() : Array
      {
         return this.m_stencils;
      }
      
      public function get lookbookImages() : Array
      {
         return this.m_lookbookImages;
      }
      
      public function get bragFrequencyKey() : String
      {
         return m_featureName + this.ASK_FEED_FREQUENCY_KEY;
      }
      
      public function get bragTimeRemaining() : int
      {
         var time:int = 0;
         var now:int = int(GlobalEngine.serverTime / 1000);
         var lastShown:int = Global.player.getFeatureLastShown(this.bragFrequencyKey);
         var coolOffTime:int = this.m_askFeedFrequency;
         if(lastShown != 0)
         {
            time = lastShown + coolOffTime - now;
         }
         return time;
      }
      
      private function get ownedStencils() : Array
      {
         var _ownedStencils:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,FEATURE_OPTIONS_OWNED_STENCILS);
         if(!_ownedStencils)
         {
            _ownedStencils = new Array();
         }
         return _ownedStencils as Array;
      }
      
      public function getTotemPreviewURL(item:FarmItem) : String
      {
         return item.getImageByName("icon");
      }
      
      public function getStencilPreviewURL(item:FarmItem) : String
      {
         return item.getImageByName("stencilIcon");
      }
      
      public function showMainUI() : void
      {
         if(!this.mainWindow)
         {
            UI.displayPopup(this.mainWindow = new StencilWindow(m_featureName,getAssetURL(this.ASSET_MAIN)));
         }
         else
         {
            this.mainWindow.close();
            this.showMainUI();
         }
      }
      
      public function showRewardWindow(item:StencilDecoration) : void
      {
         if(!this.rewardWindow)
         {
            this.rewardWindow = new StencilRewardWindow(getAssetURL(this.ASSET_REWARD_DIALOG),item);
            UI.displayPopup(this.rewardWindow);
         }
      }
      
      public function brag(e:Event, item:StencilDecoration) : void
      {
         var _stencilBragFeed:StencilPurchaseFeed = null;
         if(this.bragTimeRemaining <= 0)
         {
            _stencilBragFeed = new StencilPurchaseFeed(item,m_featureName);
            _stencilBragFeed.shareFeed();
            Global.player.setFeatureLastShown(this.bragFrequencyKey,GlobalEngine.serverTime / 1000,true);
         }
         this.rewardWindow.close();
      }
      
      public function getCurrencyValue(item:FarmItem) : int
      {
         return item.isCash ? item.cash : item.cost;
      }
      
      public function onStencilPlace(item:StencilDecoration) : void
      {
         var _item:FarmItem = item.getItem();
         if(this.ownsStencil(_item.name))
         {
            StatsManager.count(m_featureName,this.STATS_PLACE + "_use",_item.name,this.getCurrencyValue(_item).toString(),"",Global.worldManager.currentWorldType);
            return;
         }
         this.showRewardWindow(item);
         this.addStencilToInventory(item);
         this.updateNewTags();
         this.sortStencils();
         StatsManager.count(m_featureName,this.STATS_PLACE + "_buy",_item.name,this.getCurrencyValue(_item).toString(),"",Global.worldManager.currentWorldType);
      }
      
      public function ownsStencil(itemName:String) : Boolean
      {
         if(this.ownedStencils.indexOf(itemName) >= 0)
         {
            return true;
         }
         return false;
      }
      
      public function onBuy(item:FarmItem) : void
      {
         if(!Global.player.canBuyFarmItem(item))
         {
            return;
         }
         StatsManager.count(m_featureName,this.STATS_BUY + "_" + item.currency,item.name,this.getCurrencyValue(item).toString(),"",Global.worldManager.currentWorldType);
         Global.world.enterForcePlaceMode(item.name,false,0,true,false);
         this.mainWindow.close();
      }
      
      public function onUse(item:FarmItem) : void
      {
         StatsManager.count(m_featureName,this.STATS_USE + "_" + item.currency,item.name,this.getCurrencyValue(item).toString(),"",Global.worldManager.currentWorldType);
         Global.world.enterForcePlaceMode(item.name,false,0,true,false);
         this.mainWindow.close();
      }
      
      public function clearAllStencilEffect() : void
      {
         var stencils:Array = Global.world.getObjectsByClass(StencilDecoration);
         for(var i:int = 0; i < stencils.length; i++)
         {
            (stencils[i] as StencilDecoration).hideStencilEffect();
         }
      }
      
      private function arrangeOwnedStencils() : void
      {
         var _ownedStencils:Array = new Array();
         var _unownedStencils:Array = new Array();
         for(var i:int = 0; i < this.m_stencils.length; i++)
         {
            if(this.ownsStencil(this.m_stencils[i].name))
            {
               _ownedStencils.push(this.m_stencils[i]);
            }
            else
            {
               _unownedStencils.push(this.m_stencils[i]);
            }
         }
         this.m_stencils = _ownedStencils.concat(_unownedStencils);
      }
      
      private function arrangeNewStencils() : void
      {
         var _newStencils:Array = new Array();
         var _oldStencils:Array = new Array();
         for(var i:int = 0; i < this.m_stencils.length; i++)
         {
            if(this.m_stencils[i].isNew)
            {
               _newStencils.push(this.m_stencils[i]);
            }
            else
            {
               _oldStencils.push(this.m_stencils[i]);
            }
         }
         this.m_stencils = _newStencils.concat(_oldStencils);
      }
      
      private function updateNewTags() : void
      {
         for(var i:int = 0; i < this.m_stencils.length; i++)
         {
            if(this.m_stencils[i].isNew)
            {
               this.m_stencils[i].isNew = !this.ownsStencil(this.m_stencils[i].name);
            }
         }
      }
      
      private function addStencilToInventory(item:StencilDecoration) : void
      {
         var _ownedStencils:Array = this.ownedStencils;
         _ownedStencils.push(item.getItemName());
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_OWNED_STENCILS,_ownedStencils);
      }
      
      private function loadStencils(stencils:XMLList) : void
      {
         var name:String = null;
         var isNew:Boolean = false;
         for(var i:int = 0; i < stencils.length(); i++)
         {
            name = stencils[i].@name.toString();
            isNew = int(stencils[i].@variant) == 1 ? true : false;
            this.m_stencils.push({
               "name":name,
               "isNew":isNew
            });
         }
      }
      
      private function loadLookbookImages(images:XMLList) : void
      {
         for(var i:int = 0; i < images.length(); i++)
         {
            this.m_lookbookImages.push(images[i].@path.toString());
         }
      }
      
      public function playTutorialVideo(e:Event) : void
      {
         var url:String = getString(this.DIALOG_SUFFIX_TUTORIAL_VIDEO);
         navigateToURL(new URLRequest(url),"_blank");
         StatsManager.count(m_featureName,"video_click");
      }
      
      public function sortStencils(e:Event = null) : void
      {
         this.arrangeOwnedStencils();
         this.arrangeNewStencils();
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
