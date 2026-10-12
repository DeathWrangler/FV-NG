package Managers
{
   import Classes.BushelBaby.BushelBabyNPC;
   import Classes.BushelBaby.BushelBabyNPCLevel;
   import Classes.BushelBaby.BushelBabyOrderItem;
   import Classes.BushelBaby.BushelBabySystem;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Transactions.TCancelFriendReward;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.BushelBaby.BushelBabyContentsWindow;
   import Widgets.Windows.BushelBaby.BushelBabyLevelUpWindow;
   import Widgets.Windows.BushelBaby.BushelBabyRewardWindow;
   import Widgets.Windows.ItemSelectorWindow;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class BushelBabyManager extends EventDispatcher
   {
      
      private static var s_instance:BushelBabyManager;
      
      public static const FEATURE_TYPE:String = "BushelBabySystem";
      
      public static const LEVELUP_EVENT:String = "BuildingLevelUp";
      
      public static const LEVELUP_TYPE:String = "BushelBabyLevelUp";
      
      public static const REWARD_TYPE:String = "BushelBabyReward";
      
      public static const REWARD_GIFT:String = "socialplumbingmysterygift";
      
      public static const LEVELUP_GIFT:String = "consume_coins_500";
      
      public static const NOTIFICATIONS:String = "Notifications:";
      
      public static var varToFunctionMapping:Object = {
         "unlocked":"buyNPCUnlock",
         "currentLevel":"changeLevel"
      };
      
      private var m_initialized:Boolean;
      
      private var m_systems:Object;
      
      private var m_buildingsToSystems:Object;
      
      private var m_activeWindows:Object;
      
      public function BushelBabyManager(enforcer:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(enforcer != null,"[BushelBabyManager] :: Use instance()");
         this.m_initialized = false;
         this.m_systems = {};
         this.m_buildingsToSystems = {};
         this.m_activeWindows = {};
      }
      
      public static function get instance() : BushelBabyManager
      {
         if(!s_instance)
         {
            s_instance = new BushelBabyManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public static function grantReward(name:String) : void
      {
         Global.player.addGift(name);
      }
      
      public function get initialized() : Boolean
      {
         return this.m_initialized;
      }
      
      public function init() : void
      {
         var systemName:String = null;
         var systemXML:XML = null;
         var system:BushelBabySystem = null;
         var systemNames:Array = Global.farmGameSettingsManager.getFeatureNamesByType(FEATURE_TYPE);
         if(systemNames)
         {
            for each(systemName in systemNames)
            {
               systemXML = Global.farmGameSettingsManager.getFeatureXML(systemName);
               if(systemXML)
               {
                  system = new BushelBabySystem(systemXML);
                  this.m_systems[systemName] = system;
                  if(system.buildingItemCode)
                  {
                     this.m_buildingsToSystems[system.buildingItemCode] = systemName;
                  }
               }
            }
         }
         this.m_initialized = true;
      }
      
      public function showUI(systemName:String) : void
      {
         var system:BushelBabySystem = null;
         var window:BushelBabyContentsWindow = null;
         if(this.m_initialized)
         {
            system = this.getSystem(systemName);
            if(system)
            {
               window = BushelBabyContentsWindow.display(system);
               window.addEventListener(Event.CLOSE,this.onCurrentWindowClose);
               this.m_activeWindows[systemName] = window;
            }
         }
      }
      
      public function showLevelupUi(xp:String, coins:String, onShareCallBack:Function, onCloseCallBack:Function) : void
      {
         BushelBabyLevelUpWindow.display(xp,coins,onShareCallBack,onCloseCallBack);
      }
      
      private function onCurrentWindowClose(e:Event) : void
      {
         var window:BushelBabyContentsWindow = e.currentTarget as BushelBabyContentsWindow;
         window.removeEventListener(Event.CLOSE,this.onCurrentWindowClose);
         delete this.m_activeWindows[window.system.name];
      }
      
      public function showRewardUI(system:BushelBabySystem, npcName:String, rewardType:int, farmItem:Array, subtext:String, subtext_2:String, showShare:Boolean, showClose:Boolean, shareCallBack:Function, rewardSelectCallBack:Function, closeCallBack:Function, onShareAndCloseCallBack:Function) : void
      {
         if(this.m_initialized)
         {
            if(system)
            {
               BushelBabyRewardWindow.display(system,npcName,rewardType,farmItem,subtext,subtext_2,showShare,showClose,shareCallBack,rewardSelectCallBack,closeCallBack,onShareAndCloseCallBack);
            }
         }
      }
      
      public function showCraftingUI(orderItem:BushelBabyOrderItem, onCraftComplete:Function = null) : void
      {
         /*
          * Decompilation error
          * Code may be obfuscated
          * Tip: You can try enabling "Deobfuscate code" option in Settings
          * Error type: IndexOutOfBoundsException (Index -1 out of bounds for length 0)
          */
         throw new flash.errors.IllegalOperationError("Not decompiled due to error");
      }
      
      public function showBuildingUI(buildingName:String) : void
      {
         var systemName:String = this.getSystemNameForBuilding(buildingName);
         if(systemName)
         {
            BushelBabyManager.instance.showUI(systemName);
         }
      }
      
      public function onRewardSelected(system:BushelBabySystem, npcLevel:BushelBabyNPCLevel, npcName:String, name:String, isFirstCompletion:Boolean, callBack:Function) : void
      {
         var params:Array = [system.name,npcName,system.getNPCData(npcName)[BushelBabyNPC.LEVEL_PROPERTY],name];
         TransactionManager.addTransaction(new TGenericTransaction(BushelBabySystem.SERVICE_NAME,BushelBabyManager.varToFunctionMapping[BushelBabyNPC.LEVEL_PROPERTY],this.transactionCallBack(system,npcLevel,npcName,name,isFirstCompletion,callBack),params));
      }
      
      private function transactionCallBack(system:BushelBabySystem, npcLevel:BushelBabyNPCLevel, npcName:String, name:String, isFirstCompletion:Boolean, onShareAndCloseCallBack:Function) : Function
      {
         var f:Function = function(result:Object):void
         {
            var levelUpRewardURL:String = null;
            var rewardItem:FarmItem = null;
            var reward_type_1_description:String = null;
            var reward_type_1_bottomText:String = null;
            if(result)
            {
               if(result.hasOwnProperty("rewardURL") && Boolean(result.rewardURL))
               {
                  levelUpRewardURL = null;
                  if(result.hasOwnProperty("levelUpRewardURL") && Boolean(result.levelUpRewardURL))
                  {
                     levelUpRewardURL = result.levelUpRewardURL;
                  }
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(name);
                  if(isFirstCompletion)
                  {
                     reward_type_1_description = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bushel_baby_reward_type_1_description");
                     reward_type_1_bottomText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bushel_baby_reward_type_1_bottomText");
                  }
                  else
                  {
                     reward_type_1_description = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bushel_baby_reward_type_3_description",{"animalName":rewardItem.friendlyTitle});
                     reward_type_1_bottomText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bushel_baby_reward_type_3_bottomText");
                  }
                  showRewardUI(system,npcName,BushelBabyRewardWindow.REWARD_TYPE_1,[rewardItem],reward_type_1_description,reward_type_1_bottomText,true,true,publishFeedCallBack(result.rewardURL),null,closeCallBack(result.rewardURL),onShareAndCloseCallBack(levelUpRewardURL));
               }
            }
         };
         return f;
      }
      
      private function onRewardPopUpCloseAndShareCallBack(system:BushelBabySystem, showLevelUpPopUp:Boolean, level:int, rewards:Object) : Function
      {
         var f:Function = function(rewardUrl:String):Function
         {
            var f:Function = function():void
            {
               var xp:String = null;
               var coins:String = null;
               if(showLevelUpPopUp)
               {
                  xp = "0";
                  coins = "0";
                  if(rewards)
                  {
                     if(rewards.hasOwnProperty("xp"))
                     {
                        xp = rewards["xp"];
                        Global.player.xp += int(xp);
                     }
                     if(rewards.hasOwnProperty("coins"))
                     {
                        coins = rewards["coins"];
                        Global.player.gold += int(coins);
                     }
                  }
                  BushelBabyManager.instance.showLevelupUi(xp,coins,publishLevelUpFeedCallBack(system,rewardUrl,level),onCloseLevelUpPopUpCallBack(rewardUrl));
               }
            };
            return f;
         };
         return f;
      }
      
      private function onCloseLevelUpPopUpCallBack(rewardURL:String) : Function
      {
         var f:Function = function():void
         {
            TransactionManager.addTransaction(new TCancelFriendReward([rewardURL]));
         };
         return f;
      }
      
      private function publishLevelUpFeedCallBack(system:BushelBabySystem, rewardUrl:String, level:int) : Function
      {
         var f:Function = function():void
         {
            var notificationsName:String = null;
            var rewardFarmItem:FarmItem = null;
            var bundleData:Object = null;
            if(rewardUrl)
            {
               notificationsName = BushelBabyManager.NOTIFICATIONS + system.name;
               rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByName(BushelBabyManager.LEVELUP_GIFT);
               bundleData = {
                  "reward_link":rewardUrl,
                  "rewardName":rewardFarmItem.friendlyName,
                  "subcategory":BushelBabyManager.LEVELUP_TYPE,
                  "craftingSystem":notificationsName,
                  "level":level - 1,
                  "creative":BushelBabyManager.LEVELUP_GIFT,
                  "number":(level - 1) * 5,
                  "images":[{
                     "href":"{SN_APP_URL}" + rewardUrl,
                     "src":rewardFarmItem.getImageByName(FarmItem.ICON_FEED)
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(BushelBabyManager.LEVELUP_TYPE,bundleData,[],false);
            }
         };
         return f;
      }
      
      private function closeCallBack(rewardURL:String) : Function
      {
         var f:Function = function():void
         {
            TransactionManager.addTransaction(new TCancelFriendReward([rewardURL]));
         };
         return f;
      }
      
      private function onRewardSelectCallBack(system:BushelBabySystem, npcLevel:BushelBabyNPCLevel, npcName:String, callBack:Function) : Function
      {
         var f:Function = function(name:String):void
         {
            onRewardSelected(system,npcLevel,npcName,name,false,callBack);
         };
         return f;
      }
      
      private function publishFeedCallBack(rewardUrl:String) : Function
      {
         var f:Function = function(system:BushelBabySystem, npcName:String, name:String):void
         {
            var notificationsName:String = null;
            var rewardFarmItem:FarmItem = null;
            var animalItem:FarmItem = null;
            var bundleData:Object = null;
            if(rewardUrl)
            {
               notificationsName = BushelBabyManager.NOTIFICATIONS + system.name;
               rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByName(BushelBabyManager.REWARD_GIFT);
               animalItem = Global.farmGameSettingsManager.getFarmItemByName(name);
               bundleData = {
                  "reward_link":rewardUrl,
                  "rewardName":rewardFarmItem.friendlyName,
                  "subcategory":BushelBabyManager.REWARD_TYPE,
                  "craftingSystem":notificationsName,
                  "creative":BushelBabyManager.REWARD_GIFT,
                  "animalName":animalItem.friendlyName,
                  "images":[{
                     "href":"{SN_APP_URL}" + rewardUrl,
                     "src":rewardFarmItem.getImageByName(FarmItem.ICON_FEED)
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(BushelBabyManager.REWARD_TYPE,bundleData,[],false);
            }
         };
         return f;
      }
      
      public function showSwapUI(count:int, onComplete:Function, selectedItems:Object = null, rejectionList:Object = null) : void
      {
         UI.displayPopup(new ItemSelectorWindow(FarmItemType.BUSHEL,count,onComplete,selectedItems,rejectionList),false,"ExchangeAddWindow",true);
      }
      
      private function onAnimalComplete(npcLevel:BushelBabyNPCLevel) : void
      {
         var items:Array = null;
         var level:BushelBabyNPCLevel = null;
         var desc:String = null;
         var bottomText:String = null;
         var system:BushelBabySystem = null;
         var npcName:String = null;
         var rewardPopUpCloseAndShareCallBack:Function = null;
         var rewardSelectCallBack:Function = null;
         var completed:int = 0;
         var completedNPCs:int = 0;
         var buildingLevel:int = 0;
         var npcs:Vector.<BushelBabyNPC> = null;
         var index:int = 0;
         var object:Object = null;
         var showLevelUpPopUp:Boolean = false;
         if(npcLevel.npc.hasCompletedBefore())
         {
            items = [];
            for each(level in npcLevel.npc.levels)
            {
               items.push(level.item);
            }
            desc = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bushel_baby_reward_type_2_description");
            bottomText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bushel_baby_reward_type_2_bottomText");
            system = npcLevel.npc.system;
            npcName = npcLevel.npc.name;
            rewardPopUpCloseAndShareCallBack = this.onRewardPopUpCloseAndShareCallBack(npcLevel.npc.system,false,-1,null);
            rewardSelectCallBack = this.onRewardSelectCallBack(npcLevel.npc.system,npcLevel,npcLevel.npc.name,rewardPopUpCloseAndShareCallBack);
            this.showRewardUI(system,npcName,BushelBabyRewardWindow.REWARD_TYPE_2,items,desc,bottomText,true,false,null,rewardSelectCallBack,null,null);
            npcLevel.npc.incrementComplete();
         }
         else
         {
            completed = 0;
            for each(npcLevel in npcLevel.npc.levels)
            {
               if(npcLevel.npc.complete)
               {
                  completed++;
               }
            }
            completedNPCs = npcLevel.npc.system.completedNPCCount();
            buildingLevel = npcLevel.npc.system.buildingLevel;
            if(completed > 0 && completedNPCs % BushelBabySystem.LEVELUP_CONST == 0)
            {
               object = {"system":npcLevel.npc.system};
               dispatchEvent(new DynamicObjectEvent(BushelBabyManager.LEVELUP_EVENT,object));
               showLevelUpPopUp = true;
            }
            this.onRewardSelected(npcLevel.npc.system,npcLevel,npcLevel.npc.name,npcLevel.item.name,true,this.onRewardPopUpCloseAndShareCallBack(npcLevel.npc.system,showLevelUpPopUp,buildingLevel,npcLevel.npc.system.buildingLevelRewards(buildingLevel)));
            npcLevel.npc.incrementComplete();
            npcs = npcLevel.npc.system.npcs;
            index = npcs.indexOf(npcLevel.npc) + 1;
            if(index < npcs.length)
            {
               npcs[index].setUnlocked(false);
            }
         }
      }
      
      public function getCurrentBuildLevel(systemName:String) : int
      {
         var result:int = 1;
         if(this.m_systems.hasOwnProperty(systemName))
         {
            result = int(this.m_systems[systemName].buildingLevel);
         }
         return result;
      }
      
      public function completeNPCLevel(npcLevel:BushelBabyNPCLevel) : void
      {
         var orderItem:BushelBabyOrderItem = null;
         var makeTransaction:Boolean = false;
         var pos:Point = null;
         var fontColor:uint = 0;
         var hasEnoughIngredients:Boolean = true;
         for each(orderItem in npcLevel.orderItems)
         {
            if(!orderItem.hasEnough)
            {
               GlobalEngine.assert(false,"BushelBabyManager : Not enough ingredients to upgrade to " + npcLevel.friendlyItemTitle);
               hasEnoughIngredients = false;
            }
         }
         if(hasEnoughIngredients)
         {
            for each(orderItem in npcLevel.orderItems)
            {
               Global.player.craftingState.decrementBushelBabiesCraftItem(orderItem.item.code,orderItem.numRequired);
            }
            makeTransaction = true;
            if(npcLevel.npc.levelsUntilCompletion == 1)
            {
               makeTransaction = false;
            }
            npcLevel.npc.upgradeLevel(makeTransaction);
            if(npcLevel.npc.complete)
            {
               this.onAnimalComplete(npcLevel);
               pos = new Point(Global.stage.mouseX + 10,Global.stage.mouseY + 10);
               fontColor = 16777215;
               UI.displayStatus(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"GenericExpansion_completed_text"),pos.x,pos.y,npcLevel.item.iconUrl,null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,fontColor);
            }
            else
            {
               pos = new Point(Global.stage.mouseX + 10,Global.stage.mouseY + 10);
               fontColor = 16777215;
               UI.displayStatus(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"floating_text_1"),pos.x,pos.y,npcLevel.item.iconUrl,null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,fontColor);
            }
            npcLevel.npc.system.refreshCurrentWindow();
         }
      }
      
      public function getSystem(systemName:String) : BushelBabySystem
      {
         return this.m_systems[systemName];
      }
      
      public function getSystemForBuilding(buildingName:String) : BushelBabySystem
      {
         return this.getSystem(this.m_buildingsToSystems[buildingName]);
      }
      
      public function getSystemNameForBuilding(buildingName:String) : String
      {
         return this.m_buildingsToSystems[buildingName];
      }
      
      public function arePrerequisitesMet(systemName:String) : Boolean
      {
         var system:BushelBabySystem = null;
         var result:Boolean = false;
         if(this.m_initialized)
         {
            system = this.getSystem(systemName);
            if(system)
            {
               result = system.arePrerequisitesMet();
            }
         }
         return result;
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
