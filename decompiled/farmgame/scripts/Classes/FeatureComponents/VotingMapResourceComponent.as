package Classes.FeatureComponents
{
   import Classes.FeatureDataObjects.FeatureFriendSet;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.VotingFeatureFriendSet;
   import Classes.Friend;
   import Classes.MapResource;
   import Classes.Player;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.FeatureMessageEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.VotingDataManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.CraftingArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class VotingMapResourceComponent
   {
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var DEFAULT_ARROW_SIZE_X:Number = 40.05;
      
      protected static var DEFAULT_ARROW_SIZE_Y:Number = 50.3;
      
      public var m_nextArrowIndicatorCheckTimeMs:Number = 0;
      
      private const ANTIQUE_MUSEUM_BUILDING:String = "antiquemuseum";
      
      public var m_showingProgression:Boolean = false;
      
      public var m_arrow:DisplayObject;
      
      private const ARROW_INDICATOR_CHECK_INTERVAL_MS:Number = 3000;
      
      private var m_context:MapResource;
      
      private var m_friendSetTransactionStarted:Boolean = false;
      
      private var m_imageNameMappings:Array;
      
      private var m_stateChange:Boolean = false;
      
      public function VotingMapResourceComponent(inContext:MapResource, imageNameMapping:Array)
      {
         super();
         this.m_context = inContext;
         this.m_imageNameMappings = imageNameMapping;
         Global.world.addEventListener(VotingComponent.VOTING_STATE_CHANGE,this.onStateChange,false,0,true);
      }
      
      public function loadObject(data:Object) : void
      {
         this.m_nextArrowIndicatorCheckTimeMs = GlobalEngine.currentTime;
      }
      
      private function getFriendSet() : void
      {
         var friendSetCode:String = null;
         var friendSet:VotingFeatureFriendSet = null;
         var votingManager:VotingDataManager = VotingDataManager.getInstance();
         var xml:XML = this.getGameSettingsXml();
         if(!this.m_friendSetTransactionStarted && TransactionManager.canSendTransactions() && votingManager.getDataObject(this.context.getItemName()).friendSet == null)
         {
            this.m_friendSetTransactionStarted = true;
            if(Boolean(xml) && xml.hasOwnProperty("friendSet"))
            {
               friendSetCode = xml.friendSet;
               friendSet = new VotingFeatureFriendSet(friendSetCode,-2,this.onInitializeFriendSet);
               friendSet.initializeData();
            }
         }
      }
      
      private function onInitializeFriendSet(friendSet:FriendSet, result:Object) : void
      {
         if(Boolean(result) && !result.hasOwnProperty("error"))
         {
            VotingDataManager.getInstance().getDataObject(this.context.getItemName()).friendSet = friendSet as VotingFeatureFriendSet;
         }
      }
      
      public function onUpdate(delta:Number) : void
      {
         this.checkArrowIndicator();
      }
      
      public function updateToolTipText() : void
      {
         var toolTip:String = "";
         if(this.context.isHighlighted())
         {
            if(this.m_arrow == null)
            {
               toolTip += ZLocUtils.tk_pk_asTitle("Items:" + this.context.getItemName() + "_friendlyName") + "\n";
               if(!Global.worldManager.isVisiting() && this.context.getItemName() != this.ANTIQUE_MUSEUM_BUILDING)
               {
                  if(VotingDataManager.getInstance().isAskForVotesEnabled(this.context.getItemName()))
                  {
                     toolTip += ZLocUtils.t_pk(VotingComponent.getLocalizedKey(this.context.getItemName(),"VotingStageTooltip"));
                  }
               }
            }
         }
         this.context.setToolTip(toolTip);
      }
      
      private function generateArrowIndicator(friend:Friend, numOthers:int = 0) : DisplayObject
      {
         var result:ArrowIndicatorWindow = null;
         var itemName:String = this.context.getItemName();
         var friendName:String = friend.name;
         var title:String = ZLocUtils.tk_pk_asTitle("Items:" + itemName + "_friendlyName");
         var text:String = "";
         if(numOthers <= 0)
         {
            text = ZLocUtils.t_pk(VotingComponent.getLocalizedKey(itemName,"ArrowTextSingular"),null,{"friendName":friendName});
         }
         else if(this.canRedeem(numOthers + 1))
         {
            text = ZLocUtils.t("Voting","ArrowTextRedeemNow");
         }
         else
         {
            text = ZLocUtils.t_pk(VotingComponent.getLocalizedKey(itemName,"ArrowTextPlural"),null,{
               "friendName":friendName,
               "numOthers":numOthers
            });
         }
         if(friend.picture)
         {
            result = new ArrowIndicatorWindow(friend.picture,title,text,null,true);
         }
         else
         {
            result = new ArrowIndicatorWindow(Player.NO_PROFILE_PIC_URL,title,text,null,true);
         }
         return result;
      }
      
      private function canRedeem(numVoters:int) : Boolean
      {
         var bExpired:Boolean = false;
         var result:Boolean = false;
         var bCrewFull:Boolean = false;
         var votingDataManager:VotingDataManager = VotingDataManager.getInstance();
         if(votingDataManager.isInitialized)
         {
            bCrewFull = votingDataManager.getCurrentFriendSetState(this.context.getItemName()) == VotingDataManager.IS_CREW_FULL;
            bExpired = votingDataManager.getVoteExpirationTime(this.context.getItemName()) - GlobalEngine.serverTime / 1000 <= 0;
            result = bCrewFull || bExpired && numVoters >= votingDataManager.getVotesNeededForPrize(this.context.getItemName());
         }
         return result;
      }
      
      private function checkArrowIndicator() : void
      {
         var displayObject:DisplayObject = null;
         var featureName:String = null;
         var friendSet:FeatureFriendSet = null;
         var numOthers:int = 0;
         var friendData:Friend = null;
         var askForVotesEnabled:Boolean = false;
         var title:String = null;
         var text:String = null;
         var messages:Object = null;
         if(!UI.isShowingPopup() && !Global.worldManager.isVisiting())
         {
            if(this.m_arrow == null)
            {
               featureName = this.context.getItemName();
               friendSet = VotingDataManager.getInstance().getDataObject(featureName).friendSet;
               if(friendSet == null)
               {
                  this.getFriendSet();
               }
               else
               {
                  if(friendSet.pendingFriends.length > 0)
                  {
                     numOthers = friendSet.pendingFriends.length - 1;
                     friendData = Global.friendManager.getFriendData(friendSet.pendingFriends[0]);
                     if(Boolean(friendData) && Boolean(friendData.name))
                     {
                        this.m_arrow = this.generateArrowIndicator(friendData,numOthers);
                        this.m_showingProgression = true;
                     }
                  }
                  else if(this.canShowPreOffboardArrow())
                  {
                     this.m_arrow = this.generatePreOffBoardingArrowIndicator();
                  }
                  else if(!VotingDataManager.getInstance().getFeatureCompleted(featureName))
                  {
                     askForVotesEnabled = VotingDataManager.getInstance().isAskForVotesEnabled(featureName);
                     if(askForVotesEnabled)
                     {
                        title = ZLocUtils.tk_pk_asTitle("Dialogs:VotingReadyArrowTitle");
                        text = ZLocUtils.tk_pk_asTitle("Dialogs:VotingReadyArrowText");
                        this.m_arrow = new ArrowIndicatorWindow(Player.NO_PROFILE_PIC_URL,title,text,null,true);
                     }
                  }
                  if(this.canRedeem(friendSet.pendingFriends.length))
                  {
                     messages = {};
                     messages[FeatureMessageEvent.MESSAGES_CALLTOACTION] = ZLocUtils.t("Dialogs","FOTW_CTA_voting_canredeem");
                     FeatureMessagingManager.getInstance().dispatchFeatureMessage(new FeatureMessageEvent(FeatureMessageEvent.FEATUREUPDATE,featureName,messages));
                  }
               }
            }
            displayObject = this.context.getDisplayObject();
            if(this.m_arrow != null && displayObject != null)
            {
               (displayObject as Sprite).addChild(this.m_arrow);
               this.m_arrow.visible = true;
               this.setArrowPosition(displayObject);
            }
         }
      }
      
      protected function generatePreOffBoardingArrowIndicator() : DisplayObject
      {
         var result:ArrowIndicatorWindow = null;
         var text:String = "";
         var item:FarmItem = this.context.getItem();
         var featureName:String = item.name;
         var icon:String = item.icon;
         var offBoard:Array = Global.farmGameSettingsManager.getBuildingOffBoardData(featureName);
         if(offBoard.hasOwnProperty("timeLeftText"))
         {
            text = ZLocUtils.t("Dialogs",ZLocUtils.getExistingLocalizationKey("Dialogs",item.name + "_Offboarding_Body",item.className + "_Offboarding_Body"),{"item":ZLocUtils.tk_pk_asTitle(item.friendlyName)});
            text += " " + offBoard["timeLeftText"];
         }
         else
         {
            text += ZLocUtils.t("Dialogs",ZLocUtils.getExistingLocalizationKey("Dialogs",item.name + "_PostParty_Body",item.className + "_PostParty_Body"),{"item":ZLocUtils.tk_pk_asTitle(item.friendlyName)});
         }
         return new CraftingArrowIndicatorWindow(icon,text,null,false,true);
      }
      
      protected function canShowPreOffboardArrow() : Boolean
      {
         var lastShown:int = 0;
         var featureFrequency:int = 0;
         var currentTime:int = 0;
         var result:Boolean = false;
         var item:FarmItem = this.context.getItem();
         var featureName:String = item.name;
         var offBoard:Array = Global.farmGameSettingsManager.getBuildingOffBoardData(featureName);
         var featureFlag:String = null;
         if(offBoard != null && offBoard.hasOwnProperty("isPreOffBoard") && offBoard["isPreOffBoard"] == true)
         {
            featureFlag = featureName + "_preOffboard_countdown";
            lastShown = Global.player.getFeatureLastShown(featureFlag);
            featureFrequency = Global.farmGameSettingsManager.getNumber(featureName + "PreOffboardCountdownFeatureFrequency",86400);
            currentTime = GlobalEngine.serverTime / 1000;
            if(currentTime > lastShown + featureFrequency)
            {
               Global.player.setFeatureLastShown(featureFlag,currentTime,true);
               result = true;
            }
         }
         else if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            featureFlag = featureName + "_offboard";
            lastShown = Global.player.getFeatureLastShown(featureFlag);
            featureFrequency = Global.farmGameSettingsManager.getNumber(featureName + "OffboardFeatureFrequency",86400);
            currentTime = GlobalEngine.serverTime / 1000;
            if(currentTime > lastShown + featureFrequency)
            {
               Global.player.setFeatureLastShown(featureFlag,currentTime,true);
               result = true;
            }
         }
         return result;
      }
      
      public function hideArrowDisplay() : void
      {
         if(Boolean(this.m_arrow) && Boolean(this.m_arrow.visible) && this.m_arrow.parent != null)
         {
            this.m_arrow.visible = false;
            this.m_arrow.parent.removeChild(this.m_arrow);
            this.m_arrow = null;
            this.context.conditionallyRedraw(true);
         }
      }
      
      public function set imageNameMappings(map:Array) : void
      {
         this.m_imageNameMappings = map;
      }
      
      public function getCurrentImageName() : String
      {
         var imageName:String = null;
         var index:int = 0;
         var stage:int = 0;
         var finalResult:int = -1;
         var currentWinner:int = 0;
         var votingDataManager:VotingDataManager = VotingDataManager.getInstance();
         if(votingDataManager.isInitialized)
         {
            finalResult = votingDataManager.getDataObject(this.context.getItemName()).finalResult;
            stage = votingDataManager.getDataObject(this.context.getItemName()).stage;
            currentWinner = votingDataManager.getCurrentWinner(this.context.getItemName());
            if(stage == -1)
            {
               stage = 0;
            }
         }
         else
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.onUpdateImage,false,0,true);
         }
         imageName = "built_" + stage;
         if(this.m_imageNameMappings)
         {
            if(finalResult != -1)
            {
               if(Boolean(this.m_imageNameMappings[finalResult]) && this.m_imageNameMappings[finalResult].length > 1)
               {
                  index = this.m_imageNameMappings[finalResult].length - 1;
                  if(this.m_imageNameMappings[finalResult][index])
                  {
                     imageName = this.m_imageNameMappings[finalResult][index];
                  }
               }
            }
            else if(Boolean(this.m_imageNameMappings[currentWinner]) && Boolean(this.m_imageNameMappings[currentWinner][stage]))
            {
               imageName = this.m_imageNameMappings[currentWinner][stage];
            }
            if(this.m_stateChange)
            {
               FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_context.getItemName(),"state_level_" + imageName,"stage_change");
               this.m_stateChange = false;
            }
         }
         return imageName;
      }
      
      private function setArrowPosition(displayObject:DisplayObject) : void
      {
         var settings:XML = null;
         var xOff:int = 0;
         var yOff:int = 0;
         var point:Point = null;
         var spr:Sprite = null;
         settings = Global.farmGameSettingsManager.getFeatureXML(this.context.getItemName());
         xOff = int(settings.arrowOffset.(@name == "xOffset").@value[0]);
         yOff = int(settings.arrowOffset.(@name == "yOffset").@value[0]);
         if(Boolean(this.m_arrow) && Boolean(displayObject))
         {
            point = new Point();
            spr = displayObject as Sprite;
            this.m_arrow.scaleX = ARROW_SCALE / displayObject.scaleX;
            this.m_arrow.scaleY = ARROW_SCALE / displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = -1 * Math.min(this.m_arrow.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (spr.getChildAt(0).width - Math.min(this.m_arrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               if(point.x != this.m_arrow.x || point.y != this.m_arrow.y)
               {
                  this.m_arrow.y = point.y + yOff;
                  this.m_arrow.x = point.x + xOff;
               }
            }
         }
      }
      
      private function get context() : MapResource
      {
         return this.m_context;
      }
      
      private function getGameSettingsXml() : XML
      {
         return Global.farmGameSettingsManager.getFeatureXML(this.context.getItemName());
      }
      
      private function onUpdateImage(event:FarmGameWorldEvent) : void
      {
         this.m_context.reloadImage();
      }
      
      private function onStateChange(event:FarmGameWorldEvent) : void
      {
         this.m_stateChange = true;
         this.m_context.reloadImage();
      }
   }
}

