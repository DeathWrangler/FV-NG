package Managers
{
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUDWidgets.HudMessageNotification;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGetMOTD;
   import Widgets.Windows.FVToTECurrencyConversionWindow;
   import Widgets.Windows.MessageBoardWindow;
   import Widgets.Windows.VIPPhoneFeatureWindow;
   import com.adobe.serialization.json.JSON;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class MessageBoardManager extends BaseFeatureManager
   {
      
      private static const SERVICE_NAME:String = "MessageBoardService";
      
      public static var msg_runtimeMap:Object = new Object();
      
      protected static var m_instance:Object = {};
      
      public static const FEATURE_NAME:String = "MessageBoard";
      
      public static const VIP_PHONE_FEATURE_SUBMIT_FLAG:String = "VIP_Phone_V3_Feature_Submitted";
      
      private const KEY_SAVED_BUSHEL_PROGRESS:String = "saved_bushel_progress";
      
      public const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      private var m_messageNotification:HudMessageNotification;
      
      protected var m_featureConfigData:Object;
      
      public var m_mainWindow:MessageBoardWindow;
      
      public var m_newBadgeFlag_slot1:Boolean = true;
      
      public var m_newBadgeFlag_slot2:Boolean = true;
      
      public var m_gameLoadTimeForMessageBoard:Number;
      
      private var m_FVTECurrencyWindow:FVToTECurrencyConversionWindow;
      
      private var m_skip_timer:Timer;
      
      public function MessageBoardManager(featureName:String)
      {
         this.startQuest();
         super(featureName);
      }
      
      public static function getInstance(featureName:* = "MessageBoard") : MessageBoardManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,MessageBoardManager) as MessageBoardManager;
      }
      
      public function showToasterHud() : void
      {
         var j:* = undefined;
         var toaster:MessageBoardWindow = new MessageBoardWindow("MessageBoard","MessageBoard","assets/dialogs/message_board_dec_2019/FV_msg_board_ui.swf",80);
         ToasterManager.getInstance().addImmediate(toaster);
         var featureData:* = this.getFeatureData();
         var msgData:Object = featureData["active"];
         var idsToBeUpdated:Array = new Array();
         if(msgData)
         {
            for(j = 0; j < msgData.length; j++)
            {
               idsToBeUpdated[j] = msgData[j].id;
            }
         }
         var ids:String = "";
         if(idsToBeUpdated.length > 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateReadMessagesArray",null,[FEATURE_NAME,idsToBeUpdated]),true);
            if(idsToBeUpdated.length > 1)
            {
               ids = idsToBeUpdated[0] + ":" + idsToBeUpdated[1];
            }
            else
            {
               ids = idsToBeUpdated[0];
            }
         }
         StatsManager.count(FEATURE_NAME,"Message_Board_Neighbour_Bar","open_message",ids);
      }
      
      public function setNewBadgeFalg(slotNo:int = 0) : void
      {
         if(slotNo == 1)
         {
            this.m_newBadgeFlag_slot1 = false;
         }
         else
         {
            this.m_newBadgeFlag_slot2 = false;
         }
      }
      
      public function getBadgeSlot(slotNum:int = 0) : Boolean
      {
         if(slotNum == 1)
         {
            return this.m_newBadgeFlag_slot1;
         }
         return this.m_newBadgeFlag_slot2;
      }
      
      public function getLoadTime() : Number
      {
         return this.m_gameLoadTimeForMessageBoard;
      }
      
      public function loadMessageBoardData() : void
      {
         var dataObject:Object;
         var activeMsgs:Array;
         var readMsgs:Array;
         var featureData:Object;
         var targetedMsgs:Array;
         var ids:String;
         var o:Object = null;
         var data:* = undefined;
         var activeArrayObj:Array = null;
         var msgCount:int = 0;
         var isNewMsg:Boolean = false;
         var featureObject:Object = null;
         var startTime:Number = NaN;
         var endTime:Number = NaN;
         var now:Number = NaN;
         var msgData:Object = null;
         var text:String = null;
         var iconUrl:String = null;
         var priority:int = 0;
         var readmore:String = null;
         var msgId:int = 0;
         var category:String = null;
         var cta:String = null;
         var msg_world:String = null;
         var filteredArray:* = undefined;
         var len:int = 0;
         var messagetext:String = "";
         if(Global.flashHotParams.hasOwnProperty("MESSAGE_BOARD"))
         {
            messagetext = Global.flashHotParams["MESSAGE_BOARD"];
         }
         dataObject = com.adobe.serialization.json.JSON.decode(messagetext) as Object;
         activeMsgs = new Array();
         readMsgs = new Array();
         featureData = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(Boolean(featureData) && Boolean(featureData["read_msgs"]))
         {
            for each(o in featureData["read_msgs"])
            {
               readMsgs.push(o);
            }
         }
         targetedMsgs = new Array();
         if(Boolean(featureData) && Boolean(featureData["target_msg"]))
         {
            for each(o in featureData["target_msg"])
            {
               if(Boolean(o) && o.hasOwnProperty("id"))
               {
                  StatsManager.count(FEATURE_NAME,"Message_Board_Neighbour_Bar","new_message",o["id"]);
               }
               if(!(Boolean(o && o.hasOwnProperty("id")) && Boolean(o["id"] == "20200814") && Global.player.getSeenFlag(VIP_PHONE_FEATURE_SUBMIT_FLAG)))
               {
                  targetedMsgs.push(o);
               }
            }
         }
         if(targetedMsgs.length > 0)
         {
            dataObject = dataObject.concat(targetedMsgs);
         }
         ids = "";
         if(dataObject.length > 0)
         {
            for each(data in dataObject)
            {
               msg_runtimeMap[data["id"]] = data["msg"];
               startTime = -1;
               endTime = 9999999999;
               if(data["start"])
               {
                  startTime = Number(data["start"]);
               }
               if(data["end"])
               {
                  endTime = Number(data["end"]);
               }
               now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               if(now > startTime && now < endTime)
               {
                  msgData = new Object();
                  text = data["msg"];
                  iconUrl = "";
                  priority = 5;
                  readmore = "";
                  msgId = 0;
                  category = "";
                  cta = "";
                  msg_world = "";
                  if(data["icon"])
                  {
                     iconUrl = data["icon"];
                  }
                  if(data["category"])
                  {
                     category = data["category"];
                  }
                  if(data["id"])
                  {
                     msgId = int(data["id"]);
                  }
                  if(data["cta"])
                  {
                     cta = data["cta"];
                  }
                  if(data["priority"])
                  {
                     priority = int(data["priority"]);
                  }
                  if(data["readmore"])
                  {
                     readmore = data["readmore"];
                  }
                  if(data["msg_world"])
                  {
                     msg_world = data["msg_world"];
                  }
                  msgData["msg"] = text;
                  msgData["priority"] = priority;
                  msgData["id"] = msgId;
                  msgData["icon"] = iconUrl;
                  msgData["category"] = category;
                  msgData["cta"] = cta;
                  msgData["readmore"] = readmore;
                  msgData["msg_world"] = msg_world;
                  ids = ids + ":" + msgId;
                  activeMsgs.push(msgData);
               }
            }
            activeMsgs.sortOn("priority");
            activeArrayObj = new Array();
            if(activeMsgs.length >= 2)
            {
               activeArrayObj.push(activeMsgs[0]);
               activeArrayObj.push(activeMsgs[1]);
            }
            else if(activeMsgs.length == 1)
            {
               activeArrayObj.push(activeMsgs[0]);
            }
            msgCount = 0;
            isNewMsg = false;
            if(Boolean(readMsgs) && Boolean(activeArrayObj) && readMsgs.length > 0)
            {
               filteredArray = readMsgs.filter(function(array_el:*):*
               {
                  return activeArrayObj.filter(function(anotherOne_el:*):*
                  {
                     return anotherOne_el.id == array_el;
                  }).length == 1;
               });
            }
            StatsManager.count(FEATURE_NAME,"Message_Board_Neighbour_Bar","new_message",ids);
            featureObject = this.getFeatureData();
            featureObject["active"] = activeArrayObj;
            if(filteredArray)
            {
               if(filteredArray.length >= 2)
               {
                  featureObject["msgCount"] = 0;
                  featureObject["isNewMsg"] = "No";
               }
               else if(filteredArray.length == 0 && activeArrayObj.length > 0)
               {
                  featureObject["msgCount"] = activeArrayObj.length;
                  featureObject["isNewMsg"] = activeArrayObj.length > 0 ? "Yes" : "No";
               }
               else if(filteredArray.length > 0 || activeArrayObj.length > 0)
               {
                  len = activeArrayObj.length - filteredArray.length;
                  featureObject["msgCount"] = len;
                  featureObject["isNewMsg"] = len > 0 ? "Yes" : "No";
               }
            }
            else if(activeArrayObj)
            {
               featureObject["msgCount"] = activeArrayObj.length;
            }
            setFeatureData(featureObject);
         }
         this.m_gameLoadTimeForMessageBoard = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         this.startSinkWaitTime();
      }
      
      public function startSinkWaitTime() : void
      {
         this.m_skip_timer = new Timer(1000);
         this.m_skip_timer.addEventListener(TimerEvent.TIMER,this.onskipWaitTimer);
         this.m_skip_timer.start();
      }
      
      public function onskipWaitTimer(event:TimerEvent) : void
      {
         var gameLoadTime:Number = MessageBoardManager.getInstance().getLoadTime();
         var hudTime:int = 0;
         if(Global.flashHotParams.hasOwnProperty("MESSAGE_HUD_MOVEMENT_TIME"))
         {
            hudTime = int(Global.flashHotParams["MESSAGE_HUD_MOVEMENT_TIME"]);
         }
         if(gameLoadTime <= GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - hudTime)
         {
            this.stopSinkTimer();
            this.m_messageNotification = Global.hud.getMessageNotificationHud();
            if(this.m_messageNotification)
            {
               this.m_messageNotification.stopHudMovement();
            }
            if(this.m_messageNotification)
            {
               if(this.m_messageNotification.m_main_bell)
               {
                  this.m_messageNotification.m_main_bell.visible = true;
                  this.m_messageNotification.m_main_bell.gotoAndStop(2);
               }
            }
         }
      }
      
      private function stopSinkTimer() : void
      {
         if(this.m_skip_timer)
         {
            this.m_skip_timer.stop();
            this.m_skip_timer.removeEventListener(TimerEvent.TIMER,this.onskipWaitTimer);
            this.m_skip_timer = null;
         }
      }
      
      public function getFeatureData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(!featureData)
         {
            featureData = {};
            featureData[this.KEY_SAVED_BUSHEL_PROGRESS] = {};
            featureData["ids"] = {};
            featureData["read"] = {};
            featureData["all"] = {};
            featureData["global"] = {};
            featureData["active"] = {};
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      public function triggerMOTDbyName(motd:String, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGetMOTD(motd,this.onTriggerMotdComplete),true);
      }
      
      public function openFeatureWindow(motd:String, callback:Function = null) : void
      {
         VIPPhoneFeatureWindow.launchVipPhoneFeatureFromMessageBoard();
      }
      
      public function openFeatureWindowFVTECurrency(motd:String, callback:Function = null) : void
      {
         this.m_FVTECurrencyWindow = new FVToTECurrencyConversionWindow("assets/dialogs/FV_LoyaltyBenefits_2020/FV_LoyaltyBenefits_2020.swf","FVTE","");
         UI.displayPopup(this.m_FVTECurrencyWindow);
      }
      
      public function triggerInnovationByName(featureName:String, world:String = "") : void
      {
         var orderConfig:XML = null;
         var managerName:String = null;
         var managerClass:Class = null;
         var manager:* = undefined;
         var worldType:String = world;
         if(worldType != "" && Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            orderConfig = Global.farmGameSettingsManager.getFeatureXML(featureName);
            managerName = "";
            if(orderConfig)
            {
               managerName = orderConfig["manager"]["@name"];
            }
            if(managerName == "")
            {
               managerName = featureName + "Manager";
            }
            if(managerName == "AnimalSanctuaryV2Manager")
            {
               managerClass = getDefinitionByName("Managers." + managerName) as Class;
            }
            else
            {
               managerClass = getDefinitionByName("Managers.OrderBoard." + managerName) as Class;
            }
            if(managerClass)
            {
               manager = managerClass["getInstance"].call(null,featureName);
               if(Boolean(managerClass) && Boolean(manager))
               {
                  manager.showMainWindow();
               }
            }
         }
      }
      
      private function onTriggerMotdComplete(result:Object) : void
      {
         if(result != null)
         {
            MOTD.displayMOTD(result);
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
      }
      
      public function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      public function startQuest(callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",null,[FEATURE_NAME]),true);
      }
      
      public function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
   }
}

