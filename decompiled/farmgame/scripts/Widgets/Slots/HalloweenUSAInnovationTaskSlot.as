package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.Mastery;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureOptionsManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class HalloweenUSAInnovationTaskSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_slotIcon:FarmIcon;
      
      private var m_questTitleTf:ZwTextField;
      
      private var m_questDoneTf:ZwTextField;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_checkMarkMc:MovieClip;
      
      private var m_icon_mc:FarmIcon;
      
      private var m_taskId:int;
      
      private var m_tierName:String;
      
      private var m_data:Object;
      
      private var m_task:FarmTask;
      
      private var m_toolTip:FarmTextTooltip;
      
      public function HalloweenUSAInnovationTaskSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("questtitle_tf"))
         {
            addWidget(this.m_questTitleTf = new ZwTextField(m_element["questtitle_tf"],"some title"));
         }
         if(m_element.hasOwnProperty("icon_mc") && Boolean(m_element["icon_mc"].hasOwnProperty("bounds_mc")))
         {
            (m_element["icon_mc"] as MovieClip).visible = true;
            this.m_icon_mc = new FarmIcon(m_element["icon_mc"]);
         }
         if(m_element.hasOwnProperty("questdone_tf"))
         {
            addWidget(this.m_questDoneTf = new ZwTextField(m_element["questdone_tf"],"quest done"));
         }
         if(m_element.hasOwnProperty("task_bt"))
         {
            addWidget(this.m_taskBt = new FarmAnimatedTextButton(m_element["task_bt"],"Open",null));
         }
         if(m_element.hasOwnProperty("skip_bt"))
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element["skip_bt"],"Skip","15",this.skipCallback));
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkMarkMc = m_element["checkmark_mc"] as MovieClip;
         }
      }
      
      public function taskCallback(evt:Event) : void
      {
         var currentTierName:String = null;
         if(this.m_task)
         {
            currentTierName = "";
            if(HalloweenInnovationManager.getInstance().mainWindow)
            {
               currentTierName = HalloweenInnovationManager.getInstance().mainWindow.currentTabName();
            }
            FarmStatsManager.count("RockPaperShivers","task_button",currentTierName,this.m_task.action,this.m_task.type,"perform_action");
            HalloweenInnovationManager.getInstance().closeMainUI();
            this.m_task.performHelperAction(null,this.testCallback);
         }
      }
      
      private function testCallback(obj:Object) : void
      {
      }
      
      override public function populate(data:Object) : void
      {
         var modifiedIconUrl:String = null;
         var item:FarmItem = null;
         var itemFriendlyName:String = null;
         this.m_data = data;
         this.m_task = data.obj as FarmTask;
         this.m_taskBt.callback = this.taskCallback;
         this.m_taskBt.enabled = true;
         this.m_skipBt.setAmountText(this.m_task.skipCashValue.toString());
         this.m_questDoneTf.visible = this.m_questTitleTf.visible = this.m_taskBt.visible = this.m_skipBt.visible = this.m_checkMarkMc.visible = true;
         var featureData:Object = HalloweenInnovationManager.getInstance().getFeatureOption();
         this.m_taskBt.text = this.getKingdomText();
         this.m_questTitleTf.text = this.getHelperText();
         var currentProgress:int = this.getCurrentProgress();
         this.m_questDoneTf.text = currentProgress.toString() + "/" + this.m_task.level;
         if(this.m_task.action == QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE)
         {
            this.m_questDoneTf.text = currentProgress.toString() + "/" + (this.m_task.level - 1).toString();
         }
         if(data.hasOwnProperty("status") && data.status == 1 || Boolean(featureData["tiers"].hasOwnProperty(data.taskId)))
         {
            this.m_questDoneTf.visible = false;
            this.m_checkMarkMc.visible = true;
            this.m_skipBt.visible = false;
            this.m_taskBt.visible = false;
         }
         else
         {
            this.m_checkMarkMc.visible = false;
            this.m_skipBt.visible = true;
         }
         if(this.m_task.iconUrl)
         {
            modifiedIconUrl = this.getIconUrl();
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
            if(!item)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_task.extraData.craftingSystem);
            }
            itemFriendlyName = "";
            if(item)
            {
               itemFriendlyName = item.friendlyTitle;
            }
            this.m_icon_mc.visible = true;
            this.m_icon_mc.loadIcon(modifiedIconUrl);
            if(this.m_toolTip)
            {
               this.m_toolTip.setText(itemFriendlyName);
            }
            else
            {
               this.m_icon_mc.attachTooltip(this.m_toolTip = new FarmTextTooltip(itemFriendlyName));
            }
         }
      }
      
      private function getIconUrl() : String
      {
         var iconUrl:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_LEVEL:
               iconUrl = "assets/buildings/xha_elitehorses_icon.png";
               break;
            case QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CODE:
               iconUrl = this.m_task.iconUrl;
               break;
            case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
               iconUrl = this.m_task.iconUrl;
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
               iconUrl = "assets/buildings/building_xha_bigbuildable_10_icon.png";
               break;
            default:
               iconUrl = this.m_task.iconUrl;
         }
         return iconUrl;
      }
      
      private function getCurrentProgress() : int
      {
         var mastery:Mastery = null;
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var objects:Array = null;
         var item:FarmItem = null;
         var levelMasteryCount:int = 0;
         var code:String = null;
         var masteryCounters:Object = null;
         var currentMasteryCount:int = 0;
         var animalObject:Object = null;
         var levelsDataArray:Array = null;
         var i:int = 0;
         var levels:XMLList = null;
         var level:XML = null;
         var currentProgressLevel:int = 0;
         var fo:Object = HalloweenInnovationManager.getInstance().getFeatureOption();
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_LEVEL:
               craftingSystem = FeatureCraftingManager.instance.getSystem("xha_elitehorses");
               npcData = craftingSystem.npcData;
               for each(animalObject in npcData)
               {
                  if(animalObject.hasOwnProperty("complete"))
                  {
                     if(animalObject["complete"] == true)
                     {
                        currentProgressLevel++;
                     }
                  }
               }
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               objects = Global.world.getObjectsByCode(this.m_task.type);
               if(objects.length == 1)
               {
                  currentProgressLevel = (objects[0] as FeatureBuilding).storageLevel - 1;
               }
               break;
            case QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CODE:
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
               code = this.m_task.type;
               masteryCounters = Global.player.masteryCounters;
               currentMasteryCount = 0;
               if(masteryCounters.hasOwnProperty(code))
               {
                  currentMasteryCount = int(masteryCounters[code]);
               }
               mastery = Global.farmGameSettingsManager.getMasteryByCode(this.m_task.type);
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  levelsDataArray = mastery.levelsData;
                  for(i = 0; i < levelsDataArray.length; i++)
                  {
                     levelMasteryCount = int(levelsDataArray[i].getInt("count"));
                     if(currentMasteryCount >= levelMasteryCount)
                     {
                        currentProgressLevel++;
                     }
                  }
               }
               else
               {
                  levels = mastery.levels;
                  for each(level in levels)
                  {
                     levelMasteryCount = int(level.@count);
                     if(currentMasteryCount >= levelMasteryCount)
                     {
                        currentProgressLevel++;
                     }
                  }
               }
               break;
            case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
               if(fo)
               {
                  currentProgressLevel = int(fo[this.m_task.type]);
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
               if(fo)
               {
                  currentProgressLevel = int(fo["1kgy"]);
               }
         }
         return currentProgressLevel;
      }
      
      private function getKingdomText() : String
      {
         var result:String = "";
         switch(this.m_task.helperType)
         {
            case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
            case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
               result = "Open";
               break;
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               result = "Plant";
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               result = "Craft";
               break;
            case QuestConstants.HELPER_TYPE_PAN_TO_ITEM:
               result = "Show";
         }
         return result;
      }
      
      public function getHelperText() : String
      {
         var itemName:String = null;
         var lockedState:int = 0;
         var requestText:String = "";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
         var isInHalloweenFarm:Boolean = Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HALLOWEENUSA;
         if(item)
         {
            itemName = item.friendlyTitle;
         }
         switch(this.m_task.helperType)
         {
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               requestText = "Master to level " + this.m_task.level.toString();
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               requestText = "Craft " + this.m_task.level.toString() + " " + itemName;
               lockedState = CraftingManager.getInstance().isRecipeLocked(this.m_task.type);
               if(lockedState > 0)
               {
                  this.m_taskBt.callback = null;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,CraftingManager.getInstance().getRecipeLockedReason(this.m_task.type,lockedState));
               }
               break;
            case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
               requestText = "Fill " + this.m_task.level.toString() + " orders";
               break;
            case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
               requestText = "Earn reward No. " + (this.m_task.level - 1).toString();
               if(!isInHalloweenFarm)
               {
                  this.m_taskBt.callback = this.travelBtCallback;
               }
               break;
            case QuestConstants.HELPER_TYPE_PAN_TO_ITEM:
               if(this.m_task.action == QuestConstants.TASK_UNLOCK_TILE)
               {
                  requestText = "Unlock " + itemName;
               }
               else if(this.m_task.action == QuestConstants.TASK_HARVEST_BY_CODE)
               {
                  requestText = "Harvest " + this.m_task.level.toString() + " times";
               }
               if(!isInHalloweenFarm)
               {
                  this.m_taskBt.callback = this.travelBtCallback;
               }
               break;
            default:
               requestText = "Open";
         }
         return requestText;
      }
      
      private function skipCallback(event:MouseEvent) : void
      {
         UI.displayMessage("Do you want to spend " + this.m_task.skipCashValue.toString() + " FC to complete this task?",GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"",true);
      }
      
      private function updateAfterSkip(result:Object) : void
      {
         HalloweenInnovationManager.getInstance().refreshTab();
      }
      
      private function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         var featureData:Object = null;
         var currentTierName:String = "";
         if(HalloweenInnovationManager.getInstance().mainWindow)
         {
            currentTierName = HalloweenInnovationManager.getInstance().mainWindow.currentTabName();
         }
         if(event.button == GenericPopup.YES)
         {
            if(Global.player.canBuyCash(this.m_task.skipCashValue))
            {
               featureData = HalloweenInnovationManager.getInstance().getFeatureOption();
               if(!featureData.hasOwnProperty("tiers"))
               {
                  featureData["tiers"] = new Object();
               }
               featureData["tiers"][this.m_data.taskId] = 1;
               Global.player.cash -= this.m_task.skipCashValue;
               this.m_checkMarkMc.visible = true;
               this.m_questDoneTf.visible = false;
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = false;
               FarmStatsManager.count("RockPaperShivers","skip_task",currentTierName,this.m_task.action,this.m_task.type,this.m_task.skipCashValue.toString());
               FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,this.m_featureName,featureData);
               TransactionManager.addTransaction(new TGenericTransaction("HalloweenUSAInnovationService","skipTask",this.updateAfterSkip,[this.m_featureName,this.m_data.taskId]));
            }
         }
      }
      
      private function travelBtCallback(event:MouseEvent) : void
      {
         var currentTierName:String = "";
         if(HalloweenInnovationManager.getInstance().mainWindow)
         {
            currentTierName = HalloweenInnovationManager.getInstance().mainWindow.currentTabName();
         }
         FarmStatsManager.count("RockPaperShivers","task_button",currentTierName,this.m_task.action,this.m_task.type,"open_travel_dialog");
         if(HalloweenInnovationManager.getInstance().mainWindow)
         {
            HalloweenInnovationManager.getInstance().mainWindow.close();
         }
         Global.hud.travelNameDisplay.showNewTravelWindow();
      }
   }
}

