package Managers
{
   import Classes.Avatar.PartyAvatar;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.ConstructionBuilding;
   import Classes.FeatureDataObjects.FeatureFriendSet;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.PartyDataObject;
   import Classes.PartyBuilding;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmTask;
   import Display.FarmDynamicDialog;
   import Display.Party.RoyalWeddingPartyDialog;
   import Display.Party.TeaPartyDialog;
   import Display.QueuedIcons.QuestQueuedIcon;
   import Display.UI;
   import Engine.Classes.ObjectLayer;
   import Engine.Helpers.Vector3;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Party.BuildingPartyWindow;
   import ZQuest.Classes.Quest;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import gs.TweenLite;
   
   public class PartyManager
   {
      
      private static var m_objInstance:PartyManager;
      
      public static const PARTY_AVATAR_LAYER:String = "party_avatar_layer";
      
      private static const FADE_OUT_TIME_IN_SEC:int = 2;
      
      public static const MAX_GUEST_LINE:Number = 8;
      
      public static const CENTER_PARTY_OFFSET:Number = 3;
      
      public static const CENTER_PLACEMENT:String = "center";
      
      public static const BUILDING_PLACEMENT:String = "building";
      
      public static const PARTY_WINDOW_NEW_YEARS:String = "BuildingPartyWindow";
      
      public static const PARTY_WINDOW_DIALOG_NAME:String = "partyWindow";
      
      public static const PARTY_DIALOG_PACKAGE:String = "Display.Party.";
      
      private var m_partyObjects:Dictionary = new Dictionary();
      
      private var m_partyWindowOpen:Boolean = false;
      
      private var m_autoPublish:Boolean = false;
      
      private var m_customMessageInput:ZwTextField;
      
      private var m_partyDialogClasses:Array = [TeaPartyDialog,RoyalWeddingPartyDialog];
      
      public function PartyManager(objEnforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : PartyManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new PartyManager(new SingletonEnforcer());
         }
         return m_objInstance;
      }
      
      public function initializePartyDataObjects() : void
      {
         var code:String = null;
         var activeFriendSets:Array = Global.farmGameSettingsManager.getActiveFriendSets();
         for each(code in activeFriendSets)
         {
            if(null == this.m_partyObjects[code])
            {
               this.initializePartyDataObject(code);
            }
         }
      }
      
      private function initializePartyDataObject(code:String) : void
      {
         var partyDataObject:PartyDataObject = new PartyDataObject(code);
         this.m_partyObjects[code] = partyDataObject;
         partyDataObject.addEventListener(Event.COMPLETE,this.onPartyDataObjectInit);
         partyDataObject.initializeFriendSetData();
      }
      
      private function onPartyDataObjectInit(event:Event) : void
      {
         var partyDataObject:PartyDataObject = null;
         var code:String = null;
         var nonNeighbors:Array = null;
         event.target.removeEventListener(event.type,arguments.callee);
         partyDataObject = event.target as PartyDataObject;
         if(partyDataObject)
         {
            code = partyDataObject.friendSetCode;
            if(partyDataObject.partyPlacement)
            {
               nonNeighbors = partyDataObject.friendSet.nonNeighborAcceptedFriends;
               Global.friendManager.initializeFriendsMetaDataForUids(nonNeighbors,function(result:Object):void
               {
                  placePartyAvatars(code,partyDataObject.partyPlacement);
               });
               if(partyDataObject.shouldAutoComplete)
               {
                  if(partyDataObject.goal.isCompleted())
                  {
                     this.triggerQuestComplete(partyDataObject.friendSetCode);
                     if(partyDataObject.friendSet is FeatureFriendSet)
                     {
                        FeatureFriendSet(partyDataObject.friendSet).completionSeen();
                     }
                  }
               }
            }
         }
      }
      
      private function placePartyAvatars(code:String, partyPlacement:String) : void
      {
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(code);
         switch(partyPlacement)
         {
            case PartyManager.CENTER_PLACEMENT:
               this.placeFarmCenteredPartyAvatars(code);
               break;
            case PartyManager.BUILDING_PLACEMENT:
               this.placeBuildingPartyAvatars(code);
               break;
            default:
               this.placeFarmCenteredPartyAvatars(code);
         }
      }
      
      private function placeFarmCenteredPartyAvatars(code:String) : void
      {
         var centerPosition:Vector3 = new Vector3();
         centerPosition.x = Math.round(Global.world.getGridWidth() * 0.5) + PartyManager.CENTER_PARTY_OFFSET;
         centerPosition.y = Global.world.getGridHeight() * 0.5;
      }
      
      public function placeBuildingPartyAvatars(code:String) : void
      {
         var constructionBuildings:Array = null;
         var possibleBarn:ConstructionBuilding = null;
         var avatarPosition:Vector3 = null;
         var startingPosition:Vector3 = null;
         var partyBuildings:Array = Global.world.getObjectsByClass(PartyBuilding);
         if(!startingPosition && Boolean(partyBuildings[0]))
         {
            startingPosition = (partyBuildings[0] as PartyBuilding).getPosition();
         }
         if(!startingPosition)
         {
            constructionBuildings = Global.world.getObjectsByClass(ConstructionBuilding);
            for each(possibleBarn in constructionBuildings)
            {
               if(possibleBarn.buildingName == "NewYearsConstruction")
               {
                  startingPosition = possibleBarn.getPosition();
               }
            }
         }
         if(startingPosition)
         {
            avatarPosition = startingPosition;
         }
         if(avatarPosition)
         {
            this.placePartyAvatarsAtPosition(code,avatarPosition);
         }
      }
      
      private function placePartyAvatarsAtPosition(code:String, startingAvatarPosition:Vector3) : void
      {
         var uid:String = null;
         var friendPartyAvatar:PartyAvatar = null;
         var friendSet:FriendSet = this.getPartyObjectByCode(code).friendSet;
         var objLayer:ObjectLayer = new ObjectLayer(PartyManager.PARTY_AVATAR_LAYER);
         Global.world.addLayer(objLayer);
         var numAvatarsPlaced:int = 0;
         var pendingFriends:Array = friendSet.pendingFriends;
         for each(uid in pendingFriends)
         {
            if(numAvatarsPlaced < PartyManager.MAX_GUEST_LINE)
            {
               friendPartyAvatar = new PartyAvatar(uid,code);
               Global.world.addAvatar(friendPartyAvatar,startingAvatarPosition);
               startingAvatarPosition.x += 1;
               numAvatarsPlaced++;
            }
         }
      }
      
      public function fadeOutAllPartyAvatars(code:String, doMarkFriendSet:Boolean = true, doDisplayPartyWindow:Boolean = true) : void
      {
         var partyAvatar:PartyAvatar = null;
         var partyAvatars:Array = Global.world.getObjectsByClass(PartyAvatar);
         for each(partyAvatar in partyAvatars)
         {
            TweenLite.to(partyAvatar.getDisplayObject(),FADE_OUT_TIME_IN_SEC,{
               "alpha":0,
               "onComplete":this.removeAllPartyAvatars,
               "onCompleteParams":[code,doMarkFriendSet,doDisplayPartyWindow]
            });
         }
         this.triggerQuestProgress(code);
         FarmStatsManager.count("FriendSet_" + code,"PartyAvatars","click_to_fade");
      }
      
      private function removeAllPartyAvatars(code:String, doMarkFriendSet:Boolean = true, doDisplayPartyWindow:Boolean = true) : void
      {
         var partyAvatar:PartyAvatar = null;
         var partyAvatars:Array = Global.world.getObjectsByClass(PartyAvatar);
         for each(partyAvatar in partyAvatars)
         {
            partyAvatar.detach();
         }
         if(doMarkFriendSet)
         {
            this.getPartyObjectByCode(code).friendSet.markSeen();
         }
         if(doDisplayPartyWindow)
         {
            this.displayPartyWindow(code);
         }
      }
      
      public function getPartyObjectByCode(code:String) : PartyDataObject
      {
         if(null == this.m_partyObjects[code])
         {
            this.initializePartyDataObject(code);
         }
         return this.m_partyObjects[code];
      }
      
      public function getPartyWindow(code:String) : FarmDynamicDialog
      {
         var partyWindowDialogName:String = null;
         var partyWindowClassName:String = null;
         var partyDialogClass:Class = null;
         var partyWindow:FarmDynamicDialog = null;
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(code);
         if(friendSetXml.hasOwnProperty(PartyManager.PARTY_WINDOW_DIALOG_NAME))
         {
            partyWindowDialogName = friendSetXml[PartyManager.PARTY_WINDOW_DIALOG_NAME];
            partyWindowClassName = PartyManager.PARTY_DIALOG_PACKAGE + partyWindowDialogName;
            partyDialogClass = getDefinitionByName(PartyManager.PARTY_DIALOG_PACKAGE + partyWindowDialogName) as Class;
            partyWindow = FarmDynamicDialog.createDialog(partyWindowDialogName,partyDialogClass) as FarmDynamicDialog;
         }
         return partyWindow;
      }
      
      public function displayPartyWindow(code:String) : void
      {
         var partyWindow:FarmDynamicDialog = null;
         var partyDataObj:PartyDataObject = this.m_partyObjects[code];
         if(partyDataObj.isInitialized)
         {
            if(!this.m_partyWindowOpen)
            {
               partyWindow = this.getPartyWindow(code);
               if(partyWindow != null)
               {
                  partyWindow.setup();
                  partyWindow.show();
                  this.m_partyWindowOpen = true;
               }
            }
         }
         else
         {
            partyDataObj.addEventListener(Event.COMPLETE,function(event:Event):void
            {
               event.target.removeEventListener(event.type,arguments.callee);
               displayPartyWindow(code);
            });
         }
      }
      
      public function displayBuildingPartyWindow(code:String, building:PartyBuilding = null, constructionBuilding:ConstructionBuilding = null) : void
      {
         var partyBuildings:Array = null;
         var constructionBuildings:Array = null;
         var possibleBarn:ConstructionBuilding = null;
         if(building == null)
         {
            partyBuildings = Global.world.getObjectsByClass(PartyBuilding);
            if(partyBuildings[0])
            {
               building = partyBuildings[0];
            }
         }
         if(constructionBuilding == null)
         {
            constructionBuildings = Global.world.getObjectsByClass(ConstructionBuilding);
            for each(possibleBarn in constructionBuildings)
            {
               if(possibleBarn.buildingName == "NewYearsConstruction")
               {
                  constructionBuilding = possibleBarn;
               }
            }
         }
         if(Boolean(this.getPartyObjectByCode(code)) && Boolean(this.getPartyObjectByCode(code).friendSet.initialized) && this.getPartyObjectByCode(code).accessible)
         {
            UI.displayPopup(new BuildingPartyWindow(building,constructionBuilding,code));
            this.m_partyWindowOpen = true;
         }
      }
      
      public function inviteFriendToPartyCode(uid:String, code:String, message:String = "") : void
      {
         var partyData:PartyDataObject = this.getPartyObjectByCode(code);
         if(partyData)
         {
            partyData.friendSet.inviteFriend(uid,this.autoPublish,message);
         }
      }
      
      public function get partyWindowOpen() : Boolean
      {
         return this.m_partyWindowOpen;
      }
      
      public function set partyWindowOpen(windowOpen:Boolean) : void
      {
         this.m_partyWindowOpen = windowOpen;
      }
      
      public function set autoPublish(autoPublish:Boolean) : void
      {
         this.m_autoPublish = autoPublish;
      }
      
      public function get autoPublish() : Boolean
      {
         return this.m_autoPublish;
      }
      
      public function set customMessageInput(textField:ZwTextField) : void
      {
         this.m_customMessageInput = textField;
      }
      
      public function get customMessageInput() : ZwTextField
      {
         return this.m_customMessageInput;
      }
      
      private function triggerQuestProgress(code:String) : void
      {
         var icon:QuestQueuedIcon = null;
         var quest:FarmQuest = this.getAssociatedQuest(code);
         if(quest != null)
         {
            icon = quest.getQueuedIcon();
            if(icon != null)
            {
               icon.attachArrow(ArrowType.ARROWUPDATE);
            }
         }
      }
      
      private function triggerQuestComplete(code:String) : void
      {
         var icon:QuestQueuedIcon = null;
         var quest:FarmQuest = this.getAssociatedQuest(code);
         if(quest != null)
         {
            icon = quest.getQueuedIcon();
            if(icon != null)
            {
               icon.attachArrow(ArrowType.ARROWNEW,true);
            }
         }
      }
      
      private function getAssociatedQuest(code:String) : FarmQuest
      {
         var activeQuests:Vector.<Quest> = FarmQuestManager.getInstance().getActiveQuests();
         var quest:FarmQuest = null;
         var questTask:FarmTask = null;
         var action:String = null;
         var type:String = null;
         var foundQuest:FarmQuest = null;
         for each(quest in activeQuests)
         {
            for each(questTask in quest.farmTasks)
            {
               if(questTask.action == QuestConstants.TASK_COMPLETE_FRIENDSET)
               {
                  if(questTask.type == code)
                  {
                     foundQuest = quest;
                     break;
                  }
               }
            }
            if(foundQuest != null)
            {
               break;
            }
         }
         return foundQuest;
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
