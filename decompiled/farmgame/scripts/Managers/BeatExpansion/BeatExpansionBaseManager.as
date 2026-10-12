package Managers.BeatExpansion
{
   import Cache.Classes.ZCacheUtil;
   import Classes.BeatExpansionTaskDefinition;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.CraftingCottageBuilding;
   import Classes.FeatureBuilding;
   import Classes.MystreeNursery;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftLevel;
   import Classes.crafting.CraftTypeState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.GenericPopup;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.QueuedIcons.TaskListQueuedIcon;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureOptionsManager;
   import Managers.MystreeReskinManager;
   import Transactions.TMarkQuestAsViewed;
   import Widgets.Windows.MystreeNurseryWindow;
   import ZQuest.Classes.Quest;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   
   public class BeatExpansionBaseManager
   {
      
      public static const ACTION_OPEN_CRAFTING_COTTAGE:String = "openCottage";
      
      public static const ACTION_OPEN_MASTERY:String = "openMaster";
      
      public static const ACTION_OPEN_STORAGE:String = "openStorage";
      
      public static const ACTION_OPEN_FEATURE_CRAFTING:String = "openFeatureCrafting";
      
      public static const ACTION_OPEN_MYSTREE:String = "open_mystree";
      
      public static const ACTION_OPEN_MARKET_ON_ITEM_CATEGORY:String = "openMarketOnItemCategory";
      
      private static const PURCHASE_BUILDING_UPGRADE:String = "buyBuildingUpdate";
      
      private static const PURCHASE_CRAFT_UPGRADE:String = "buyCraftingUpdate";
      
      private static const PURCHASE_FARM_EXPANSION:String = "buyFarmExpansion";
      
      public static const CURRENCY_CASH:String = "cash";
      
      public static const CURRENCY_COIN:String = "coin";
      
      protected var m_questName:String;
      
      protected var m_farmQuest:FarmQuest;
      
      protected var m_icon:QueuedIconWithArrow;
      
      protected var m_imageUrls:Object;
      
      protected var m_rewardImageUrls:Array;
      
      protected var m_questListenersActive:Boolean;
      
      protected var m_data:Array;
      
      protected var m_localizationPrefix:String;
      
      protected var m_iconName:String;
      
      protected var m_featureName:String;
      
      public var ztrack:Function;
      
      public function BeatExpansionBaseManager(featureName:String, locPrefix:String, iconName:String, statCounterName:String)
      {
         super();
         this.m_featureName = featureName;
         this.m_localizationPrefix = locPrefix;
         this.m_iconName = iconName;
         this.ztrack = ZCacheUtil.applyPartial(StatsManager.count,null,["dialog",statCounterName,"main_dialog"]);
      }
      
      public function get localizationPrefix() : String
      {
         return this.m_localizationPrefix;
      }
      
      public function get queuedLocalizationPrefix() : String
      {
         return this.m_localizationPrefix.replace("_","QueuedIcon_");
      }
      
      public function get windowLocalizationPrefix() : String
      {
         return this.m_localizationPrefix.replace("_","Window_");
      }
      
      public function init() : void
      {
         var i:int = 0;
         var list:XMLList = null;
         var listLength:int = 0;
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(feature)
         {
            this.m_questName = feature.@questName;
            this.m_imageUrls = [];
            list = feature.taskImages.image;
            listLength = list.length();
            for(i = 0; i < listLength; i++)
            {
               this.m_imageUrls[list[i].@name.toString()] = list[i].@url.toString();
            }
            this.m_rewardImageUrls = [];
            list = feature.rewardImages.image;
            listLength = list.length();
            for(i = 0; i < listLength; i++)
            {
               this.m_rewardImageUrls[list[i].@name.toString()] = list[i].@url.toString();
            }
            if(!this.m_questListenersActive)
            {
               this.m_questListenersActive = true;
               QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
            }
            this.checkQuestActive();
         }
         else if(this.m_icon)
         {
            this.conditionallyRemoveIcon();
            if(this.m_questListenersActive)
            {
               QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
               this.m_questListenersActive = false;
            }
         }
      }
      
      private function checkQuestActive() : void
      {
         var quest:Quest = null;
         var specialQuest:FarmQuest = null;
         var shownThisSession:Boolean = false;
         var lastShown:int = 0;
         var curTime:int = 0;
         var diffTime:int = 0;
         this.m_farmQuest = null;
         var activeQuests:Vector.<Quest> = FarmQuestManager.getInstance().getActiveQuests();
         for each(quest in activeQuests)
         {
            if(quest.name == this.m_questName)
            {
               this.m_farmQuest = quest as FarmQuest;
               break;
            }
         }
         specialQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(this.m_questName) as FarmQuest;
         if(Boolean(this.m_farmQuest) && Boolean(!this.m_icon) || !this.m_icon && this.isSpecialTaskQuest(specialQuest) && !this.allSubQuestsComplete(specialQuest))
         {
            TaskListQueuedIcon.removeHUDIcon();
            this.m_icon = Global.hud.iconQueue.addIcon(this.m_iconName,DynamicIconQueue.ADD_BY_PRIORITY,null,{},false) as QueuedIconWithArrow;
            shownThisSession = Global.player.getSeenSessionFlag(this.m_featureName + "_seenHudTooltip");
            if(!shownThisSession)
            {
               Global.player.setSeenSessionFlag(this.m_featureName + "_seenHudTooltip");
               lastShown = Global.player.getFeatureLastShown(this.m_featureName + "_hudNew");
               curTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               diffTime = curTime - lastShown;
               if(diffTime < FarmGameUtil.NUM_SECS_IN_DAY)
               {
                  this.m_icon.attachArrow(ArrowType.ARROWNEW);
               }
               else if(diffTime > FarmGameUtil.NUM_SECS_IN_DAY * 7)
               {
                  this.m_icon.attachArrow(ArrowType.ARROWNEW);
                  Global.player.setFeatureLastShown(this.m_featureName + "_hudNew",curTime,true);
               }
            }
         }
         else if(this.m_farmQuest == null && this.m_data == null)
         {
            this.conditionallyRemoveIcon();
         }
      }
      
      private function conditionallyRemoveIcon() : void
      {
         if(this.m_icon)
         {
            Global.hud.iconQueue.removeIconByName(this.m_iconName);
            this.m_icon = null;
         }
      }
      
      private function allSubQuestsComplete(quest:FarmQuest) : Boolean
      {
         var child:Object = null;
         var areAllComplete:Boolean = true;
         var bubbleQuestName:String = quest.chain + "Bubble-01-001";
         var bubbleQuest:FarmQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(bubbleQuestName) as FarmQuest;
         for each(child in bubbleQuest.children)
         {
            if(FarmQuestManager.getInstance().isQuestActive(child.value))
            {
               areAllComplete = false;
               break;
            }
         }
         return areAllComplete;
      }
      
      private function isSpecialTaskQuest(quest:FarmQuest) : Boolean
      {
         var isSpecial:Boolean = false;
         if(Boolean(quest) && Boolean(quest.taskCompletionCount))
         {
            isSpecial = true;
         }
         return isSpecial;
      }
      
      private function onQuestUpdates(event:QuestEvent) : void
      {
         this.checkQuestActive();
         if(event.quest.name == this.m_questName && !(event.quest as FarmQuest).isNew)
         {
            if(this.m_icon)
            {
               this.m_icon.attachArrow(ArrowType.ARROWUPDATE);
            }
         }
      }
      
      public function displayUI() : void
      {
      }
      
      public function setQuestAsSeen() : void
      {
         var farmQuest:FarmQuest = null;
         if(this.m_farmQuest)
         {
            farmQuest = this.m_farmQuest;
         }
         else
         {
            farmQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(this.m_questName) as FarmQuest;
         }
         if(Boolean(farmQuest) && farmQuest.isNew == true)
         {
            TransactionManager.addTransaction(new TMarkQuestAsViewed(farmQuest.name));
            farmQuest.setAsSeen();
         }
      }
      
      public function isQuestActive() : Boolean
      {
         return this.m_farmQuest != null;
      }
      
      public function getTaskData() : Array
      {
         var nameToIndex:Object = null;
         var total:int = 0;
         var progress:int = 0;
         var purchase:String = null;
         var price:int = 0;
         var currency:String = null;
         var butVisible:Boolean = false;
         var farmTasks2:Vector.<FarmTask> = null;
         var taskDefinition:BeatExpansionTaskDefinition = null;
         var bubbleQuestName:String = null;
         var m_bubbleQuest:FarmQuest = null;
         var child:Object = null;
         var childQuest:FarmQuest = null;
         var questTask:FarmTask = null;
         var name:String = null;
         var task:FarmTask = null;
         var objs:Array = null;
         var index:int = 0;
         var craftTypeState:CraftTypeState = null;
         var taskIndex:int = 0;
         var gridX:int = 0;
         var gridY:int = 0;
         var targetExpansion:ChangeFarmItem = null;
         var nextExpansion:ChangeFarmItem = null;
         var startFarmSize:Number = NaN;
         var obj:FeatureBuilding = null;
         var nextLevel:CraftLevel = null;
         var remainingExp:int = 0;
         nameToIndex = [];
         var farmTasks:Vector.<FarmTask> = new Vector.<FarmTask>();
         var taskQuest:FarmQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(this.m_questName) as FarmQuest;
         if(this.m_farmQuest)
         {
            farmTasks = this.m_farmQuest.farmTasks;
         }
         else if(Boolean(taskQuest) && Boolean(this.isSpecialTaskQuest(taskQuest)) && !this.allSubQuestsComplete(taskQuest))
         {
            farmTasks2 = new Vector.<FarmTask>();
            bubbleQuestName = taskQuest.chain + "Bubble-01-001";
            m_bubbleQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(bubbleQuestName) as FarmQuest;
            for each(child in m_bubbleQuest.children)
            {
               if(child.value != taskQuest.name)
               {
                  childQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(child.value) as FarmQuest;
                  if(!FarmQuestManager.getInstance().isQuestActive(childQuest.name))
                  {
                     for each(questTask in childQuest.farmTasks)
                     {
                        questTask.setTaskProgressToTotal();
                        farmTasks2.push(questTask);
                     }
                  }
                  else
                  {
                     for each(questTask in childQuest.farmTasks)
                     {
                        farmTasks2.push(questTask);
                     }
                  }
               }
            }
            farmTasks = farmTasks2;
         }
         if(Boolean(this.m_farmQuest) || Boolean(taskQuest && this.isSpecialTaskQuest(taskQuest)) && Boolean(!this.allSubQuestsComplete(taskQuest)))
         {
            this.m_data = [];
            for each(task in farmTasks)
            {
               switch(task.action)
               {
                  case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
                     name = "buildable_" + task.type;
                     progress = task.progress;
                     total = task.total;
                     objs = Global.world.getObjectsByCode(task.type);
                     if(objs[0])
                     {
                        obj = objs[0] as FeatureBuilding;
                        if(obj)
                        {
                           progress = obj.storageLevel - 1;
                           total = task.extraData.level - 1;
                           if(progress < total)
                           {
                              price = obj.nextExpansionCashNeeded();
                              if(price > 0)
                              {
                                 purchase = PURCHASE_BUILDING_UPGRADE;
                                 currency = CURRENCY_CASH;
                              }
                           }
                        }
                     }
                     nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],progress,total,ACTION_OPEN_STORAGE,[task.type],this.m_imageUrls[name + "_reward"],purchase,price,currency));
                     break;
                  case QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CODE:
                     name = "master_crops";
                     index = int(nameToIndex[name]);
                     if(index)
                     {
                        taskDefinition = this.m_data[index - 1] as BeatExpansionTaskDefinition;
                        taskDefinition.progress += task.progress;
                        taskDefinition.total += task.total;
                        taskDefinition.args.push(task.type);
                     }
                     else
                     {
                        nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],task.progress,task.total,ACTION_OPEN_MASTERY,[task.type],this.m_imageUrls[name + "_reward"]));
                     }
                     break;
                  case QuestConstants.TASK_REACH_CRAFT_SKILL_LEVEL:
                     name = "craft_skill";
                     progress = task.progress;
                     total = task.total;
                     craftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(task.type);
                     if(craftTypeState)
                     {
                        progress = craftTypeState.level - 1;
                        total = task.extraData.level - 1;
                        nextLevel = Global.craftConfigSettings.getCraftLevel(craftTypeState.level + 1);
                        if(nextLevel)
                        {
                           remainingExp = nextLevel.experience - craftTypeState.experience;
                           purchase = PURCHASE_CRAFT_UPGRADE;
                           if(remainingExp > 0)
                           {
                              price = nextLevel.cashCost;
                              currency = CURRENCY_CASH;
                           }
                           else
                           {
                              price = nextLevel.goldCost;
                              currency = CURRENCY_COIN;
                           }
                        }
                     }
                     butVisible = CraftingManager.getInstance().getPlacedCraftingCottages().length != 0;
                     nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],progress,total,ACTION_OPEN_CRAFTING_COTTAGE,[task.type],this.m_imageUrls[name + "_reward"],purchase,price,currency,butVisible));
                     break;
                  case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
                     name = "make_recipe_" + task.type;
                     progress = task.progress;
                     total = task.total;
                     if(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LAB_BUILDING,task.type))
                     {
                        progress = task.total;
                     }
                     butVisible = Global.world.getObjectsByCode(task.extraData["building"]).length != 0;
                     nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],progress,total,ACTION_OPEN_STORAGE,[task.extraData["building"]],this.m_imageUrls[name + "_reward"],null,0,null,butVisible));
                     break;
                  case QuestConstants.TASK_HARVEST_FEATURE_CRAFTING_STATION_BY_RECIPE:
                     name = "featureCrafting";
                     progress = task.progress;
                     total = task.total;
                     butVisible = true;
                     nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],progress,total,ACTION_OPEN_FEATURE_CRAFTING,[task.extraData["craftingSystem"]],this.m_imageUrls[name + "_reward"],null,0,null,butVisible));
                     break;
                  case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
                  case QuestConstants.TASK_VIEW_SEEN_FLAG:
                     name = "completeFeatureCraftingNPC";
                     taskIndex = int(nameToIndex[name]);
                     if(taskIndex)
                     {
                        taskDefinition = this.m_data[taskIndex - 1] as BeatExpansionTaskDefinition;
                        taskDefinition.progress += task.progress;
                        taskDefinition.total += task.total;
                        taskDefinition.args.push(task.type);
                     }
                     else
                     {
                        progress = task.progress;
                        total = task.total;
                        butVisible = true;
                        nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],progress,total,ACTION_OPEN_FEATURE_CRAFTING,[task.extraData["craftingSystem"]],this.m_imageUrls[name + "_reward"],null,0,null,butVisible));
                     }
                     break;
                  case QuestConstants.TASK_EXPAND_FARM:
                     name = "expand_" + task.type;
                     progress = task.progress;
                     total = task.total;
                     gridX = Global.world.getGridWidth();
                     gridY = Global.world.getGridHeight();
                     targetExpansion = Global.farmGameSettingsManager.getFarmItemByName(task.type) as ChangeFarmItem;
                     nextExpansion = Global.worldManager.getNextExpansion(true);
                     startFarmSize = Global.farmGameSettingsManager.getInt("farmSize");
                     progress = gridX - startFarmSize;
                     total = targetExpansion.squares - startFarmSize;
                     purchase = null;
                     currency = null;
                     if(progress < total)
                     {
                        price = nextExpansion.realCashCost;
                        if(price > 0)
                        {
                           purchase = PURCHASE_FARM_EXPANSION;
                           currency = CURRENCY_CASH;
                        }
                     }
                     nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],progress,total,ACTION_OPEN_MARKET_ON_ITEM_CATEGORY,[nextExpansion.name],this.m_imageUrls[name + "_reward"],purchase,price,currency));
                     break;
                  case QuestConstants.TASK_COMPLETE_MYSTREE_COLLECTION:
                     name = "completeMystreeCollection";
                     progress = task.progress;
                     total = task.total;
                     butVisible = true;
                     nameToIndex[name] = this.m_data.push(new BeatExpansionTaskDefinition(name,this.m_imageUrls[name],progress,total,ACTION_OPEN_MYSTREE,[task.type],this.m_imageUrls[name + "_reward"],null,0,null,butVisible));
               }
            }
         }
         return this.m_data;
      }
      
      public function executeExternalAction(actionType:String, actionArgs:Array) : void
      {
         var objs:Array = null;
         var obj:FeatureBuilding = null;
         var cottages:Array = null;
         var cottage:CraftingCottageBuilding = null;
         var targetItem:FarmItem = null;
         var buildingArray:Array = null;
         var mystreeBuilding:MystreeNursery = null;
         switch(actionType)
         {
            case ACTION_OPEN_STORAGE:
               if(actionArgs[0])
               {
                  objs = Global.world.getObjectsByCode(actionArgs[0]);
                  if(objs[0])
                  {
                     obj = objs[0] as FeatureBuilding;
                     if(obj)
                     {
                        this.ztrack("go_to_building_" + obj.bldgName);
                        obj.displayStorageDialog();
                     }
                  }
               }
               break;
            case ACTION_OPEN_CRAFTING_COTTAGE:
               if(actionArgs[0])
               {
                  cottages = CraftingManager.getInstance().getPlacedCraftingCottages();
                  for each(cottage in cottages)
                  {
                     if(Boolean(cottage) && cottage.craftType == actionArgs[0])
                     {
                        this.ztrack("go_to_crafting");
                        cottage.displayStorageDialog();
                        break;
                     }
                  }
               }
               break;
            case ACTION_OPEN_MARKET_ON_ITEM_CATEGORY:
               if(actionArgs[0])
               {
                  targetItem = Global.farmGameSettingsManager.getFarmItemByName(actionArgs[0]);
                  if(targetItem != null)
                  {
                     UI.displayMarketDialog(this.m_featureName,targetItem.type,null,targetItem.subType);
                     this.ztrack("go_to_market");
                  }
               }
               break;
            case ACTION_OPEN_FEATURE_CRAFTING:
               if(actionArgs[0])
               {
                  FeatureCraftingManager.instance.showUI(actionArgs[0]);
                  this.ztrack("go_to_featureCrafting");
               }
               break;
            case ACTION_OPEN_MYSTREE:
               if(Boolean(actionArgs) && Boolean(actionArgs[0]))
               {
                  if(actionArgs[0] == "mystree_v1")
                  {
                     buildingArray = Global.world.getObjectsByName("jacksmystreenursery");
                     if(buildingArray.length > 0)
                     {
                        mystreeBuilding = buildingArray[0];
                        UI.displayPopup(new MystreeNurseryWindow(mystreeBuilding));
                     }
                  }
                  else
                  {
                     MystreeReskinManager.getInstance(actionArgs[0]).openMystreeUI();
                  }
               }
         }
      }
      
      public function askPurchase(purchase:String, price:int, currency:String, args:Array, callback:Function) : void
      {
         var itemCode:String = args[0];
         var messageText:String = "";
         switch(purchase)
         {
            case PURCHASE_FARM_EXPANSION:
               messageText = ZLocUtils.t("Dialogs",this.m_localizationPrefix + purchase + "_" + currency,{"price":price});
               break;
            default:
               messageText = ZLocUtils.t("Dialogs",this.m_localizationPrefix + purchase + "_" + itemCode + "_" + currency,{"price":price});
         }
         if(itemCode)
         {
            UI.displayMessage(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.generatePurchaseCallback(purchase,currency,itemCode,callback),"",true);
         }
      }
      
      private function generatePurchaseCallback(purchase:String, currency:String, arg:String, callback:Function) : Function
      {
         return function(event:GenericPopupEvent):void
         {
            var objs:* = undefined;
            var cottages:* = undefined;
            var obj:* = undefined;
            var cottage:* = undefined;
            var targetExpansion:* = undefined;
            var accepted:* = event.button == GenericPopup.ACCEPT;
            if(accepted)
            {
               switch(purchase)
               {
                  case PURCHASE_BUILDING_UPGRADE:
                     objs = Global.world.getObjectsByCode(arg);
                     if(objs[0])
                     {
                        obj = objs[0] as FeatureBuilding;
                        if(obj)
                        {
                           obj.frictionlessExpand(null);
                        }
                     }
                     break;
                  case PURCHASE_CRAFT_UPGRADE:
                     CraftingManager.getInstance().buyCraftTypeUpgrade(arg,currency == CURRENCY_CASH);
                     cottages = CraftingManager.getInstance().getPlacedCraftingCottages();
                     for each(cottage in cottages)
                     {
                        if(Boolean(cottage) && cottage.craftType == arg)
                        {
                           cottage.animateUpgrade();
                           break;
                        }
                     }
                     break;
                  case PURCHASE_FARM_EXPANSION:
                     if(arg)
                     {
                        targetExpansion = Global.farmGameSettingsManager.getFarmItemByName(arg) as ChangeFarmItem;
                        if(targetExpansion != null)
                        {
                           if(Global.player.canBuyCash(targetExpansion.realCashCost))
                           {
                              UI.clearPopupQueue();
                              targetExpansion.onBuy(targetExpansion.cashName,{"currency":"cash"});
                           }
                        }
                     }
               }
            }
            if(callback != null)
            {
               callback(accepted);
            }
         };
      }
   }
}

