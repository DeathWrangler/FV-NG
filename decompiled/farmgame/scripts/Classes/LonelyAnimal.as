package Classes
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.LonelyAnimalFeatureFriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import GameMode.GMDefault;
   import Managers.FarmStatsManager;
   import Transactions.TGetLonelyAnimalFriendSetProgress;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.LonelyAnimal.LonelyAnimalCompletionWindow;
   import Widgets.Windows.LonelyAnimal.LonelyAnimalWindow;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class LonelyAnimal extends MutableAnimal
   {
      
      public static const LONELY_ANIMAL_SEEN_FLAG:String = "LONELY_ANIMAL_INTERACTED";
      
      public static const LONELY_ANIMAL_DEFAULT_COOLDOWN:Number = 1209600;
      
      public static const LONELY_ANIMAL_ASSET:String = "mustang_white";
      
      public static const LONELY_ANIMAL_FRIENDSET_CODE:String = "FS06";
      
      public static const LONELY_ANIMAL_MADE_PROGRESS:String = "lonely_animal_made_progress";
      
      public static const Y_OFFSET:Number = -8;
      
      protected static const ARROW_SCALE:Number = 0.5;
      
      protected static const DEFAULT_ARROW_SIZE_X:Number = 40.05;
      
      protected static const DEFAULT_ARROW_SIZE_Y:Number = 50.3;
      
      private static const LONELY_ANIMAL_ADDED:String = "lonely_animal_added";
      
      private static var m_canInstantiate:Boolean = false;
      
      private static var m_cachedFriendProgressResult:Object = null;
      
      private const LONELY_ANIMAL_SHRUBS_PATH:String = "assets/Environment/FV_lonelyAnimalShrub.swf";
      
      private const ARROW_Y_OFFSET:Number = 30;
      
      private const ARROW_X_OFFSET:Number = 8;
      
      private var m_lonelyAnimalWindow:LonelyAnimalWindow;
      
      protected var m_gameComplete:Boolean = false;
      
      protected var m_madeProgressArrow:DisplayObject;
      
      protected var m_madeProgress:Boolean = false;
      
      protected var m_canShowLonelyAnimal:Boolean = false;
      
      private var m_progressState:int = 0;
      
      private var m_friendSetId:Number = 0;
      
      private var m_startTime:int;
      
      private var m_finalFriendReceiveTime:int;
      
      protected var m_madeProgressClass:Class;
      
      private var m_itemFeatureFriendSet:LonelyAnimalFeatureFriendSet;
      
      private var m_shrubs:DisplayObject;
      
      private var m_ready:Boolean = false;
      
      public function LonelyAnimal(animalItem:FarmItem)
      {
         if(m_canInstantiate)
         {
            if(!Global.player.getSeenSessionFlag(LONELY_ANIMAL_ADDED))
            {
               this.m_madeProgressClass = GOLD_ARROW;
               super(animalItem.name);
               this.m_visible = false;
               this.loadObject({
                  "position":{
                     "x":0,
                     "y":0,
                     "z":0
                  },
                  "state":STATE_BARE
               });
               if(animalItem.className != "MutableAnimal")
               {
                  super.useBaseAnimalState();
               }
               Global.player.setSeenSessionFlag(LONELY_ANIMAL_ADDED);
               if(m_cachedFriendProgressResult == null)
               {
                  TransactionManager.addTransaction(new TGetLonelyAnimalFriendSetProgress(LonelyAnimal.LONELY_ANIMAL_FRIENDSET_CODE,this.onTransactionComplete,animalItem.code),false);
               }
               else
               {
                  this.onTransactionComplete(m_cachedFriendProgressResult);
               }
            }
            return;
         }
         throw new Error("Can\'t instantiate LonelyAnimal directly. Use LonelyAnimal.getLonelyAnimalInstance() instead.");
      }
      
      private static function getLonelyAnimalItem() : FarmItem
      {
         var itemName:String = null;
         var farmItem:FarmItem = null;
         if(Global.player.lonelyAnimalCode != null && Global.player.lonelyAnimalCode != "")
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(Global.player.lonelyAnimalCode);
         }
         else
         {
            itemName = Global.flashHotParams["LONELY_ANIMAL_CREW_ITEM"] != null ? Global.flashHotParams["LONELY_ANIMAL_CREW_ITEM"] : LONELY_ANIMAL_ASSET;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         return farmItem;
      }
      
      public static function getLonelyAnimalInstance() : LonelyAnimal
      {
         var runtimeItemName:String = null;
         var result:LonelyAnimal = null;
         var animalItem:FarmItem = getLonelyAnimalItem();
         if(animalItem != null)
         {
            m_canInstantiate = true;
            result = new LonelyAnimal(animalItem);
            m_canInstantiate = false;
         }
         else
         {
            runtimeItemName = Global.flashHotParams["LONELY_ANIMAL_CREW_ITEM"];
            FarmStatsManager.count("errors","lonely_animal","invalid_runtime_item",runtimeItemName);
            ErrorManager.addError("Lonely Animal item name " + runtimeItemName + " is invalid!");
         }
         return result;
      }
      
      public static function resetSeenFlag() : void
      {
         Global.player.setSeenSessionFlag(LONELY_ANIMAL_ADDED,false);
      }
      
      override public function isHarvestable() : Boolean
      {
         return false;
      }
      
      public function get madeProgress() : Boolean
      {
         return this.m_madeProgress;
      }
      
      private function onTransactionComplete(result:Object) : void
      {
         var friendData:Array = null;
         var friendSetXml:XML = null;
         var friendsNeeded:Number = NaN;
         var boughtFriendCount:int = 0;
         var cooldownTime:Number = NaN;
         var lastInteraction:Number = NaN;
         var calcTime:Number = NaN;
         var daysLeft:int = 0;
         var hoursLeft:int = 0;
         this.m_ready = true;
         if(result != null && result.indexOut != null)
         {
            m_cachedFriendProgressResult = result;
            this.attach();
            this.m_visible = true;
            setState(STATE_BARE);
            this.m_madeProgress = result.madeProgress;
            this.m_progressState = result.progressState;
            if(this.m_madeProgress || this.m_progressState > 0)
            {
               Global.player.setSeenSessionFlag(LONELY_ANIMAL_MADE_PROGRESS);
            }
            this.m_friendSetId = result.indexOut;
            this.m_itemFeatureFriendSet = FriendSet.factory(LonelyAnimal.LONELY_ANIMAL_FRIENDSET_CODE,this.m_friendSetId,null) as LonelyAnimalFeatureFriendSet;
            this.m_itemFeatureFriendSet.onInitialize(result);
            FarmStatsManager.count("lonely_animal","asset","impressions");
            friendData = [];
            friendSetXml = Global.farmGameSettingsManager.getFriendSetXMLByCode(this.m_itemFeatureFriendSet.code);
            friendsNeeded = Number(friendSetXml.numFriendsNeeded[0]);
            boughtFriendCount = Math.max(Math.min(int(this.m_itemFeatureFriendSet.getNumBoughtFriends),friendsNeeded),0);
            this.m_finalFriendReceiveTime = result.finalFriendReceiveTime;
            this.m_startTime = this.m_itemFeatureFriendSet.getStartTime();
            cooldownTime = Global.flashHotParams["LONELY_ANIMAL_CREW_COOLDOWN"] != null ? Number(Global.flashHotParams["LONELY_ANIMAL_CREW_COOLDOWN"]) : LONELY_ANIMAL_DEFAULT_COOLDOWN;
            lastInteraction = Global.player.getFeatureLastShown(LonelyAnimal.LONELY_ANIMAL_SEEN_FLAG);
            this.m_canShowLonelyAnimal = GlobalEngine.currentTime - lastInteraction > cooldownTime;
            calcTime = this.m_finalFriendReceiveTime > 0 ? this.m_finalFriendReceiveTime : int(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
            daysLeft = Math.max(0,LonelyAnimalFeatureFriendSet.NUM_DAYS_ACTIVE - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_DAY);
            hoursLeft = Math.max(0,FarmGameUtil.NUM_HOURS_IN_DAY * LonelyAnimalFeatureFriendSet.NUM_DAYS_ACTIVE - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_HOUR);
            if(hoursLeft == 0)
            {
               this.m_madeProgress = true;
            }
            FarmStatsManager.count("lonely_animal_crew_feature","animal_asset","placed");
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         m_outer = Global.world;
         var xPosition:Number = (FarmGameWorld(m_outer).getGridWidth() >> 1) - (m_size.x >> 1);
         data.position = {
            "x":xPosition,
            "y":Y_OFFSET,
            "z":0
         };
         super.loadObject(data);
      }
      
      override public function drawDisplayObject() : void
      {
         super.drawDisplayObject();
         if((this.m_madeProgress || this.m_gameComplete) && !m_hideArrow && !Global.worldManager.isVisiting())
         {
            this.showProgressArrowDisplay();
         }
      }
      
      public function showProgressArrowDisplay() : void
      {
         var spr:Sprite = null;
         this.m_hideArrow = false;
         if(this.m_madeProgressArrow == null)
         {
            this.m_madeProgressArrow = this.generateProgressArrow();
         }
         this.m_madeProgressArrow.visible = true;
         if(Boolean(this.m_madeProgressArrow) && !m_hideArrow)
         {
            spr = m_displayObject as Sprite;
            spr.addChild(this.m_madeProgressArrow);
            this.setProgressArrowPosition();
         }
      }
      
      protected function getProgressArrowBitmap() : BitmapData
      {
         return m_arrowBitmaps[this.m_madeProgressClass];
      }
      
      protected function setProgressArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(this.m_madeProgressArrow) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            this.m_madeProgressArrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            this.m_madeProgressArrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = -1 * Math.min(this.m_madeProgressArrow.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (spr.getChildAt(0).width - Math.min(this.m_madeProgressArrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               if(point.x != this.m_madeProgressArrow.x || point.y != this.m_madeProgressArrow.y)
               {
                  this.m_madeProgressArrow.y = point.y - this.ARROW_Y_OFFSET;
                  this.m_madeProgressArrow.x = point.x - this.ARROW_X_OFFSET;
               }
            }
         }
      }
      
      protected function generateProgressArrow() : DisplayObject
      {
         var arrow:DisplayObject = new this.m_madeProgressClass();
         if(m_arrowBitmaps[this.m_madeProgressClass] == null)
         {
            m_arrowBitmaps[this.m_madeProgressClass] = new BitmapData(arrow.width,arrow.height,true,0);
            m_arrowBitmaps[this.m_madeProgressClass].draw(arrow);
         }
         return arrow;
      }
      
      override protected function updateToolTipText() : void
      {
         var calcTime:Number = this.m_finalFriendReceiveTime > 0 ? this.m_finalFriendReceiveTime : int(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var daysLeft:int = Math.max(0,LonelyAnimalFeatureFriendSet.NUM_DAYS_ACTIVE - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_DAY);
         var hoursLeft:int = Math.max(0,FarmGameUtil.NUM_HOURS_IN_DAY * LonelyAnimalFeatureFriendSet.NUM_DAYS_ACTIVE - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_HOUR);
         var toolTip:String = "";
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(this.m_itemFeatureFriendSet.code);
         var friendsNeeded:Number = Number(friendSetXml.numFriendsNeeded[0]);
         if(hoursLeft > 0)
         {
            hoursLeft = Math.round(hoursLeft % FarmGameUtil.NUM_HOURS_IN_DAY);
            toolTip = ZLocUtils.t("Dialogs","LonelyAnimal_TooltipActive",{
               "daysLeft":daysLeft,
               "hoursLeft":hoursLeft,
               "friendsHelped":this.m_itemFeatureFriendSet.numFriendsCompleted,
               "friendsRequired":friendsNeeded
            });
         }
         else if(this.m_itemFeatureFriendSet.numFriends >= friendsNeeded)
         {
            toolTip = ZLocUtils.t("Dialogs","LonelyAnimal_TooltipComplete");
         }
         else
         {
            toolTip = ZLocUtils.t("Dialogs","LonelyAnimal_TooltipFailure");
         }
         if(toolTip)
         {
            setToolTip(toolTip);
         }
         updateToolTipPosition();
      }
      
      override public function onClick() : void
      {
         var farmCashSlot:Number = NaN;
         Global.player.setSeenSessionFlag(LONELY_ANIMAL_SEEN_FLAG);
         if(this.m_madeProgress || this.m_progressState > 0)
         {
            FarmStatsManager.count("lonely_animal_crew_feature","animal_asset","click_return_access");
         }
         else
         {
            FarmStatsManager.count("lonely_animal_crew_feature","animal_asset","click_first_time");
         }
         this.m_madeProgress = false;
         this.removeArrowIndicator();
         var calcTime:Number = this.m_finalFriendReceiveTime > 0 ? this.m_finalFriendReceiveTime : int(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var daysLeft:int = Math.max(0,LonelyAnimalFeatureFriendSet.NUM_DAYS_ACTIVE - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_DAY);
         var hoursLeft:int = Math.max(0,FarmGameUtil.NUM_HOURS_IN_DAY * LonelyAnimalFeatureFriendSet.NUM_DAYS_ACTIVE - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_HOUR);
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(this.m_itemFeatureFriendSet.code);
         var friendsNeeded:Number = Number(friendSetXml.numFriendsNeeded[0]);
         var missingFriends:Number = Math.max(0,friendsNeeded - this.m_itemFeatureFriendSet.numFriendsCompleted);
         if(hoursLeft <= 0 && missingFriends > 0)
         {
            farmCashSlot = Number(friendSetXml.buySlotCash[0]);
            UI.displayPopup(new LonelyAnimalCompletionWindow(false,this.m_itemFeatureFriendSet,this,farmCashSlot * missingFriends),false);
         }
         else
         {
            this.m_lonelyAnimalWindow = new LonelyAnimalWindow({
               "fsId":this.m_friendSetId,
               "lonelyAnimal":this,
               "itemName":this.getItemName()
            });
            this.m_lonelyAnimalWindow.addEventListener(CloseEvent.CLOSE,this.onLonelyAnimalWindowClose);
            UI.displayPopup(this.m_lonelyAnimalWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private function onLonelyAnimalWindowClose(event:Event) : void
      {
         if(this.m_lonelyAnimalWindow)
         {
            this.m_lonelyAnimalWindow.removeEventListener(CloseEvent.CLOSE,this.onLonelyAnimalWindowClose);
            this.m_lonelyAnimalWindow = null;
            UI.stopPopups(false);
         }
      }
      
      public function get progressState() : int
      {
         return this.m_progressState;
      }
      
      public function set progressState(progressState:int) : void
      {
         if(this.m_progressState != progressState)
         {
            this.m_progressState = progressState;
            m_cachedFriendProgressResult = null;
         }
      }
      
      public function get ready() : Boolean
      {
         return this.m_ready;
      }
      
      public function get canShow() : Boolean
      {
         return m_visible;
      }
      
      public function hideAnimal() : void
      {
         if(this.m_lonelyAnimalWindow)
         {
            this.m_lonelyAnimalWindow.close();
         }
         if(m_arrow)
         {
            m_arrow.visible = false;
            (m_displayObject as Sprite).removeChild(m_arrow);
            m_arrow = null;
         }
         this.m_lonelyAnimalWindow = null;
         m_visible = false;
         detach();
      }
      
      public function updateItemFeatureFriendSet(friendSet:LonelyAnimalFeatureFriendSet) : void
      {
         this.m_itemFeatureFriendSet = friendSet;
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return false;
      }
      
      override public function isSellable() : Boolean
      {
         return false;
      }
      
      override public function handleDecoMoveUnsupported() : void
      {
         this.onClick();
         Global.world.addGameMode(new GMDefault(),true);
      }
      
      override protected function setArrowPosition() : void
      {
         var spr:Sprite = null;
         var point:Point = null;
         if(Boolean(m_arrow) && Boolean(m_displayObject))
         {
            spr = m_displayObject as Sprite;
            m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point = new Point(0,0);
               point.y = -1.4 * Math.min(m_displayObject.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (Math.min(m_displayObject.width,DEFAULT_ARROW_SIZE_X) - spr.getChildAt(0).width) * spr.scaleX / 2;
               if(point.x != m_arrow.x || point.y != m_arrow.y)
               {
                  m_arrow.y = point.y;
                  m_arrow.x = point.x;
               }
            }
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      public function removeArrowIndicator() : void
      {
         if(Boolean(m_arrow) && Boolean(m_arrow.visible) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
         }
      }
      
      private function showShrubs(url:String = "") : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(Global.getAssetURL(url),function(event:Event):void
         {
            if(Boolean(icon) && Boolean(icon.content))
            {
               m_shrubs = icon.content;
            }
         });
      }
   }
}

