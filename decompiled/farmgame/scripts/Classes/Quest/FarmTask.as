package Classes.Quest
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Quest.helperactions.AFInnovationHelperAction;
   import Classes.Quest.helperactions.AskForItemByFeedHelperAction;
   import Classes.Quest.helperactions.AskForItemByMFSRequestHelperAction;
   import Classes.Quest.helperactions.AskForItemByRequestHelperAction;
   import Classes.Quest.helperactions.CraftingHelperAction;
   import Classes.Quest.helperactions.FeatureCraftingHelperAction;
   import Classes.Quest.helperactions.GiftboxHelperAction;
   import Classes.Quest.helperactions.GrowMysterySeedlingHelper;
   import Classes.Quest.helperactions.ItemPlaceModeHelperAction;
   import Classes.Quest.helperactions.MiniMarketHelperAction;
   import Classes.Quest.helperactions.OpenChapterQuestHelperAction;
   import Classes.Quest.helperactions.OpenMystreeHelperAction;
   import Classes.Quest.helperactions.PanToItemHelperAction;
   import Classes.Quest.helperactions.PartyHelperAction;
   import Classes.Quest.helperactions.PhotoContestHelperAction;
   import Classes.Quest.helperactions.PlantSeedHelperAction;
   import Classes.Quest.helperactions.QuestHelperAction;
   import Classes.Quest.helperactions.SpecialQuestAskForItemHelperAction;
   import Classes.Quest.helperactions.StorageBuildingDialogHelperAction;
   import Classes.Quest.helperactions.ToastHelperAction;
   import Classes.Quest.helperactions.UseFawnFeedHelperAction;
   import Classes.Quest.helperactions.UseSDBHelperAction;
   import Classes.Quest.helperactions.WatchAdHelperAction;
   import Classes.Quest.helperactions.WishListHelperAction;
   import Classes.Quest.skipactions.ExpandStorageBuildingSkipAction;
   import Classes.Quest.skipactions.FinishBuildingConstructionSkipAction;
   import Classes.Quest.skipactions.GetBushelsSkipAction;
   import Classes.Quest.skipactions.QuestSkipAction;
   import Classes.Quest.skipactions.UseRewardCreditsSkipAction;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.Quests.QuestProgressDialog;
   import Engine.Managers.ErrorManager;
   import Managers.Crafting.CraftingManager;
   import ZQuest.Init.QuestSettingsInit;
   
   public class FarmTask
   {
      
      private static const DEFAULT_ICON:String = "assets/achievements/Harvest_crops_types_icon_130.png";
      
      private static const DEFAULT_HELPER_ITEM_NAME:String = "socialplumbingmysterygift";
      
      private var m_iconUrl:String;
      
      private var m_action:String = "";
      
      private var m_type:String = "";
      
      private var m_subtype:String = "";
      
      private var m_progress:int = -1;
      
      private var m_total:int = 0;
      
      private var m_helper:String = "";
      
      private var m_cashValue:int = 0;
      
      private var m_extraData:Object = null;
      
      private var m_questName:String = "";
      
      private var m_taskIndex:int = 0;
      
      private var m_helperAction:QuestHelperAction;
      
      private var m_rewards:Vector.<Object> = null;
      
      private var m_prereqs:Array = null;
      
      private var m_id:String = "";
      
      private var m_points:int = 0;
      
      private var m_level:int = 0;
      
      private var m_widget:String;
      
      public function FarmTask(taskData:Object)
      {
         super();
         this.m_action = taskData.action;
         delete taskData.action;
         this.m_type = taskData.type;
         delete taskData.type;
         this.m_total = taskData.total;
         delete taskData.total;
         this.m_helper = taskData.helper;
         delete taskData.helper;
         this.m_cashValue = taskData.cashValue;
         delete taskData.cashValue;
         this.m_questName = taskData.questName;
         delete taskData.questName;
         this.m_taskIndex = taskData.taskIndex;
         delete taskData.taskIndex;
         this.m_rewards = taskData.rewards;
         delete taskData.rewards;
         if(taskData.id)
         {
            this.m_id = taskData.id;
            delete taskData.id;
         }
         if(taskData.points)
         {
            this.m_points = taskData.points;
            delete taskData.points;
         }
         if(taskData.level)
         {
            this.m_level = taskData.level;
         }
         this.m_subtype = taskData.subtype;
         this.m_extraData = taskData;
         this.m_widget = taskData.widget;
      }
      
      protected function generateIconKey() : String
      {
         var param:String = null;
         var result:String = this.action + "_" + this.type;
         for each(param in this.extraData)
         {
            result += "_" + param;
         }
         return result;
      }
      
      public function get skipCashValue() : int
      {
         return this.m_cashValue;
      }
      
      public function get iconUrl() : String
      {
         var item:FarmItem = null;
         var result:String = this.m_iconUrl;
         if(!result)
         {
            result = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getTaskImage(this.generateIconKey(),this.questName);
            if(!result)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.getDefaultItemName());
               if(item)
               {
                  result = item.icon;
               }
            }
            if(!result)
            {
               result = DEFAULT_ICON;
            }
            if(Global.farmGameSettingsManager.itemsXMLParsingComplete)
            {
               this.m_iconUrl = result;
            }
         }
         return result;
      }
      
      public function get action() : String
      {
         return this.m_action;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get subtype() : String
      {
         return this.m_subtype;
      }
      
      public function get total() : int
      {
         return this.m_total;
      }
      
      public function get helperType() : String
      {
         return this.m_helper;
      }
      
      public function get widget() : String
      {
         return this.m_widget;
      }
      
      public function get helperText() : String
      {
         var typeName:String = null;
         var result:String = "";
         if(this.hasHelper())
         {
            typeName = this.getTypeName();
            switch(this.m_helper)
            {
               case QuestConstants.HELPER_TYPE_PLACE_MODE:
                  result = ZLocUtils.t("Quests","Helper_Place_Button",{"item":ZLocUtils.tk_pk(typeName)});
                  break;
               case QuestConstants.HELPER_TYPE_OPEN_MARKET:
                  result = ZLocUtils.t("Quests","Helper_OpenMarket_Button",{"item":ZLocUtils.tk_pk(typeName)});
                  break;
               case QuestConstants.HELPER_TYPE_POP_TOASTER:
                  result = ZLocUtils.tk_pk_asTitle(typeName);
                  break;
               default:
                  result = this.helperAction.readableText;
            }
         }
         return result;
      }
      
      public function get cashValue() : int
      {
         var result:int = 0;
         if(this.prorateTask)
         {
            result = Math.ceil((this.m_total - this.progress) * this.pricePerAction + this.baseCashValue);
         }
         else
         {
            result = Math.ceil(this.m_total * this.pricePerAction + this.baseCashValue);
         }
         return result;
      }
      
      public function getStandardTaskSkipCost() : int
      {
         return Math.ceil(this.m_total * this.pricePerAction + this.baseCashValue);
      }
      
      public function get extraData() : Object
      {
         return this.m_extraData;
      }
      
      public function get questName() : String
      {
         return this.m_questName;
      }
      
      public function get taskIndex() : int
      {
         return this.m_taskIndex;
      }
      
      public function get targetType() : String
      {
         return (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getTaskTargetType(this.action);
      }
      
      public function isComplete() : Boolean
      {
         return this.progress >= this.m_total;
      }
      
      public function get progress() : int
      {
         var progressData:Object = null;
         var result:int = 0;
         if(this.m_progress != -1 && this.m_progress == this.m_total)
         {
            result = this.m_progress;
         }
         else
         {
            progressData = FarmQuestManager.getInstance().getQuestProgressByName(this.m_questName);
            if(progressData != null && progressData.progress != null)
            {
               if(this.m_taskIndex < progressData.progress.length)
               {
                  result = int(progressData.progress[this.m_taskIndex]);
               }
            }
         }
         return result;
      }
      
      public function setTaskProgressToTotal() : void
      {
         this.m_progress = this.m_total;
      }
      
      public function markComplete() : void
      {
         var progressData:Object = FarmQuestManager.getInstance().getQuestProgressByName(this.m_questName);
         if(progressData != null && progressData.progress != null)
         {
            if(this.m_taskIndex < progressData.progress.length)
            {
               progressData.progress[this.m_taskIndex] = this.m_total;
            }
         }
      }
      
      public function get progressPercent() : Number
      {
         return Math.min(this.progress / this.m_total,1);
      }
      
      public function get pricePerAction() : Number
      {
         var result:Number = 0;
         var progressData:Object = FarmQuestManager.getInstance().getQuestProgressByName(this.m_questName);
         if(progressData != null && progressData.pricePerAction != null)
         {
            if(this.m_taskIndex < progressData.pricePerAction.length)
            {
               result = Number(progressData.pricePerAction[this.m_taskIndex]);
            }
         }
         return result;
      }
      
      public function get baseCashValue() : Number
      {
         var result:Number = 0;
         var progressData:Object = FarmQuestManager.getInstance().getQuestProgressByName(this.m_questName);
         if(progressData != null && progressData.baseCashValue != null)
         {
            if(this.m_taskIndex < progressData.baseCashValue.length)
            {
               result = Number(progressData.baseCashValue[this.m_taskIndex]);
            }
         }
         return result;
      }
      
      public function get prorateTask() : Boolean
      {
         var result:Boolean = false;
         var progressData:Object = FarmQuestManager.getInstance().getQuestProgressByName(this.m_questName);
         if(progressData != null && progressData.prorateTask != null)
         {
            if(this.m_taskIndex < progressData.prorateTask.length)
            {
               result = Boolean(progressData.prorateTask[this.m_taskIndex]);
            }
         }
         return result;
      }
      
      public function performHelperAction(progressDialog:QuestProgressDialog = null, callback:Function = null) : void
      {
         if(this.hasHelper())
         {
            this.helperAction.callback = callback;
            this.helperAction.progressDialog = progressDialog;
            this.helperAction.perform();
         }
      }
      
      protected function get helperAction() : QuestHelperAction
      {
         var namesArray:Array = null;
         var craftingSystem:String = null;
         var recipeId:String = null;
         var zClassTracking:String = null;
         var seedItemCodes:Array = null;
         var bushelItem:FarmItem = null;
         var result:QuestHelperAction = this.m_helperAction;
         if(!result)
         {
            if(this.m_helper)
            {
               switch(this.m_helper)
               {
                  case QuestConstants.HELPER_TYPE_WISH_LIST:
                     result = new WishListHelperAction(this.m_questName,this.getDefaultItemName());
                     break;
                  case QuestConstants.HELPER_TYPE_PLACE_MODE:
                     result = new ItemPlaceModeHelperAction(this.m_questName,this.getDefaultItemName());
                     break;
                  case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED:
                     result = new AskForItemByFeedHelperAction(this.m_questName,this.getDefaultItemName(),this.getActionKey(),this.m_taskIndex);
                     break;
                  case QuestConstants.TASK_PLAY_MATCH_MAKING_FEATURE:
                     result = new AFInnovationHelperAction(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_MFS_ASK_ITEM:
                     result = new AskForItemByMFSRequestHelperAction(this.m_questName,this.getDefaultItemName(),this.getActionKey(),this.m_taskIndex);
                     break;
                  case QuestConstants.HELPER_TYPE_OPEN_MARKET:
                     namesArray = this.generateMiniMarketHelperItemNamesList();
                     result = new MiniMarketHelperAction(this.m_questName,namesArray);
                     break;
                  case QuestConstants.HELPER_TYPE_OPEN_PHOTO_CONTEST:
                     result = new PhotoContestHelperAction(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_PARTY:
                     result = new PartyHelperAction(this.m_questName,this.type);
                     break;
                  case QuestConstants.HELPER_TYPE_GIFT_BOX:
                     result = new GiftboxHelperAction(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_R4R:
                     result = new AskForItemByRequestHelperAction(this.m_questName,this.getHelperItemName());
                     break;
                  case QuestConstants.HELPER_TYPE_USE_SDB:
                     result = new UseSDBHelperAction(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_USE_FAWN_FEED:
                     result = new UseFawnFeedHelperAction(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_OPEN_MYSTERY_SEEDLING_MARKET:
                     result = new GrowMysterySeedlingHelper(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_USE_FAWN:
                     result = new GiftboxHelperAction(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
                     if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MINIRECIPE_WINDOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
                     {
                        if(this.action == QuestConstants.TASK_MAKE_RECIPE_BY_CATEGORY)
                        {
                           recipeId = CraftingManager.getValidRecipeFromCategory(this.type);
                        }
                        else
                        {
                           recipeId = this.type;
                        }
                        if(recipeId != null)
                        {
                           result = new CraftingHelperAction(this.m_questName,recipeId);
                        }
                     }
                     else if(Global.craftConfigSettings.getRecipeById(this.type) != null)
                     {
                        result = new CraftingHelperAction(this.m_questName,this.type);
                     }
                     break;
                  case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
                     craftingSystem = this.m_extraData.hasOwnProperty("craftingSystem") ? this.m_extraData.craftingSystem : this.type;
                     result = new FeatureCraftingHelperAction(this.m_questName,craftingSystem);
                     break;
                  case QuestConstants.HELPER_TYPE_POP_TOASTER:
                     result = new ToastHelperAction(this.m_questName,this.m_questName + "_" + this.m_action + "_" + this.m_type + "_Toaster",this.getHelperUrl());
                     break;
                  case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
                     result = new StorageBuildingDialogHelperAction(this.m_questName,this.m_type);
                     break;
                  case QuestConstants.HELPER_TYPE_WATCH_AD:
                     result = new WatchAdHelperAction(this.m_questName,this.m_extraData.placementId);
                     break;
                  case QuestConstants.HELPER_TYPE_PLANT_SEED:
                  case QuestConstants.HELPER_TYPE_SINK_BUSHEL:
                     if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_HELPER_PPH) == Experiments.VARIANT_FLASH_QUEST_HELPER_PPH)
                     {
                        if(this.action == QuestConstants.TASK_HARVEST_BY_CODE || this.action == QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CODE)
                        {
                           zClassTracking = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_type);
                           result = new PlantSeedHelperAction(this.m_questName,[this.m_type],zClassTracking);
                        }
                        else if(this.action == QuestConstants.TASK_HARVEST_BY_CATEGORY)
                        {
                           seedItemCodes = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemCodesInCategory(this.m_type);
                           result = new PlantSeedHelperAction(this.m_questName,seedItemCodes,this.m_type);
                        }
                        else if(this.action == QuestConstants.TASK_SINK_BUSHEL)
                        {
                           bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_type);
                           if(bushelItem.crop)
                           {
                              result = new PlantSeedHelperAction(this.m_questName,[bushelItem.crop],bushelItem.name);
                           }
                           else
                           {
                              result = new PlantSeedHelperAction(this.m_questName,[this.m_type],bushelItem.name);
                           }
                        }
                        else
                        {
                           ErrorManager.addError("Unknown task action type for plant_seed helper: " + this.action);
                        }
                     }
                     break;
                  case QuestConstants.HELPER_TYPE_OPEN_MYSTREE:
                     result = new OpenMystreeHelperAction(this.m_questName);
                     break;
                  case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED_SPECIAL_QUEST:
                     result = new SpecialQuestAskForItemHelperAction(this.m_questName,this.getDefaultItemName(),this.getActionKey(),this.m_taskIndex);
                     break;
                  case QuestConstants.HELPER_TYPE_PAN_TO_ITEM:
                     result = new PanToItemHelperAction(this.m_questName,this.type);
                     break;
                  case QuestConstants.HELPER_TYPE_CHAPTER_QUEST:
                     result = new OpenChapterQuestHelperAction(this.m_questName,this.type);
               }
               this.m_helperAction = result;
            }
         }
         return result;
      }
      
      protected function getHelperItemName() : String
      {
         var helperItemName:String = DEFAULT_HELPER_ITEM_NAME;
         if(this.extraData.hasOwnProperty("helperItem"))
         {
            helperItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(this.extraData.helperItem);
         }
         return helperItemName;
      }
      
      protected function getHelperUrl() : String
      {
         var helperUrl:String = null;
         if(this.extraData.hasOwnProperty("helperUrl"))
         {
            helperUrl = this.extraData.helperUrl;
         }
         return helperUrl;
      }
      
      protected function generateMiniMarketHelperItemNamesList() : Array
      {
         var itemsArray:Array = null;
         var item:FarmItem = null;
         var defaultItemName:String = this.getDefaultItemName();
         var namesArray:Array = new Array();
         if(defaultItemName.length > 0)
         {
            namesArray.push(defaultItemName);
         }
         else
         {
            itemsArray = this.getItemsList();
            for each(item in itemsArray)
            {
               if(item.isVisible)
               {
                  namesArray.push(item.name);
               }
            }
         }
         return namesArray;
      }
      
      public function canBeSkipped() : Boolean
      {
         return this.cashValue > 0 && !this.isComplete();
      }
      
      public function skip(dialog:QuestProgressDialog) : void
      {
         var skipAction:QuestSkipAction = null;
         switch(this.m_action)
         {
            case QuestConstants.TASK_COMPLETE_CONSTRUCTION_BY_CODE:
               skipAction = new FinishBuildingConstructionSkipAction(this.cashValue,this.questName,this.taskIndex,dialog,this.getDefaultItemName());
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               skipAction = new ExpandStorageBuildingSkipAction(this.cashValue,this.questName,this.taskIndex,dialog,this.getDefaultItemName());
               break;
            case QuestConstants.TASK_USE_REWARD_CREDIT_SPECIFIC_BUILDING_BY_CODE:
               skipAction = new UseRewardCreditsSkipAction(this.cashValue,this.questName,this.taskIndex,dialog,this.getDefaultItemName());
               break;
            case QuestConstants.TASK_GET_FRIEND_BUSHELS_BY_CODE:
               skipAction = new GetBushelsSkipAction(this.cashValue,this.questName,this.taskIndex,dialog,this.getDefaultItemName());
               break;
            default:
               skipAction = new QuestSkipAction(this.cashValue,this.questName,this.taskIndex,dialog);
         }
         if(skipAction != null)
         {
            skipAction.perform();
         }
      }
      
      protected function isActionByType(type:String) : Boolean
      {
         var result:Boolean = false;
         var taskType:String = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getTaskTargetType(this.m_action);
         if(taskType == type)
         {
            result = true;
         }
         return result;
      }
      
      public function get titleText() : String
      {
         var typeName:String = null;
         var item:FarmItem = null;
         var colonSpot:Number = NaN;
         var keySuffix:String = null;
         var keyName:String = null;
         var level:int = 0;
         var result:String = "";
         var uniqueSubTypeTitleResource:String = this.getSpecificSubTypeTitleResource();
         var uniqueResource:String = this.getSpecificTitleResource();
         if(this.m_subtype != null && ZLocUtils.hasString("Quests",uniqueSubTypeTitleResource))
         {
            result = ZLocUtils.t("Quests",uniqueSubTypeTitleResource,{"quantity":this.m_total});
         }
         else if(ZLocUtils.hasString("Quests",uniqueResource))
         {
            result = ZLocUtils.t("Quests",uniqueResource,{"quantity":this.m_total});
         }
         else
         {
            uniqueResource = this.getGenericTitleResource();
            typeName = this.m_type;
            if(this.isActionByType(QuestConstants.TASK_TYPE_CODE))
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_type);
               if(item)
               {
                  typeName = item.friendlyName;
               }
            }
            else
            {
               typeName = this.getTypeName();
            }
            if(uniqueResource == "task_doNeighborAction")
            {
               colonSpot = typeName.indexOf(":");
               keySuffix = typeName.substr(colonSpot + 1);
               keyName = uniqueResource + "_" + keySuffix;
               result = ZLocUtils.t("Quests",keyName,{"quantity":this.m_total});
            }
            else if(ZLocUtils.hasTokenAttributeInString("item","singular","Quests",uniqueResource))
            {
               if(ZLocUtils.hasString("Quests",this.m_questName + "_" + uniqueResource))
               {
                  uniqueResource = this.m_questName + "_" + uniqueResource;
                  result = ZLocUtils.t("Quests",uniqueResource,{
                     "quantity":this.m_total,
                     "item":ZLocUtils.tk_pk_asTitle(typeName)
                  });
               }
               else
               {
                  result = ZLocUtils.t("Quests",uniqueResource,{
                     "quantity":this.m_total,
                     "item":ZLocUtils.tk_pk(typeName)
                  });
               }
            }
            else if(ZLocUtils.hasTokenAttributeInString("item","plural","Quests",uniqueResource))
            {
               result = ZLocUtils.t("Quests",uniqueResource,{
                  "quantity":this.m_total,
                  "item":ZLocUtils.tk_pk(typeName,"plural")
               });
            }
            else
            {
               level = this.m_level;
               if(this.action == QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC)
               {
                  item = Global.farmGameSettingsManager.getFarmItemByName(this.m_extraData.craftingSystem);
                  if(item)
                  {
                     typeName = item.friendlyName;
                  }
               }
               else if(this.action == QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE)
               {
                  uniqueResource = uniqueResource + "_" + this.m_type;
                  level--;
               }
               result = ZLocUtils.t("Quests",uniqueResource,{
                  "level":level,
                  "quantity":this.m_total,
                  "item":ZLocUtils.tk_pk(typeName,"",this.m_total)
               });
            }
         }
         return result;
      }
      
      public function getAttribute(attrbName:String) : String
      {
         var result:String = null;
         if(this.m_extraData != null && this.m_extraData[attrbName] != null)
         {
            result = this.m_extraData[attrbName];
         }
         return result;
      }
      
      protected function getTypeName() : String
      {
         var typeResource:String = null;
         var typeName:String = this.getDefaultItemName();
         var defaultItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(typeName);
         if(defaultItem != null)
         {
            typeName = defaultItem.friendlyName;
         }
         else
         {
            typeResource = this.getTypeResource();
            typeName = "Quests:" + typeResource;
         }
         return typeName;
      }
      
      protected function getSpecificTitleResource() : String
      {
         var type:String = this.m_type == null ? "" : this.m_type;
         return this.m_questName + "_" + this.m_action + "_" + type + "_Description";
      }
      
      protected function getSpecificSubTypeTitleResource() : String
      {
         var type:String = this.m_type == null ? "" : this.m_type;
         var subtype:String = this.m_subtype == null ? "" : this.m_subtype;
         return this.m_questName + "_" + this.m_action + "_" + type + "_" + subtype + "_Description";
      }
      
      protected function getGenericTitleResource() : String
      {
         return "task_" + this.m_action;
      }
      
      protected function getTypeResource() : String
      {
         var resource:String = "";
         if(this.m_subtype != null && this.m_subtype != "")
         {
            resource = "type_" + this.m_subtype;
         }
         else
         {
            resource = "type_" + this.m_type;
         }
         return resource;
      }
      
      public function getFlavorText() : String
      {
         var resource:String = this.getSubTypeFlavorResource();
         var result:String = "";
         if(this.m_subtype != null && ZLocUtils.hasString("Quests",resource))
         {
            result = ZLocUtils.t("Quests",resource);
         }
         else
         {
            resource = this.getFlavorResource();
            result = ZLocUtils.t("Quests",resource);
         }
         return result;
      }
      
      protected function getFlavorResource() : String
      {
         var type:String = this.m_type == null ? "" : this.m_type;
         return this.m_questName + "_" + this.m_action + "_" + type + "_" + "Flavor";
      }
      
      protected function getSubTypeFlavorResource() : String
      {
         var type:String = this.m_type == null ? "" : this.m_type;
         var subtype:String = this.m_subtype == null ? "" : this.m_subtype;
         return this.m_questName + "_" + this.m_action + "_" + type + "_" + subtype + "_Flavor";
      }
      
      protected function getDefaultItemName() : String
      {
         var result:String = "";
         var targetType:String = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getTaskTargetType(this.action);
         var item:FarmItem = null;
         switch(targetType)
         {
            case "code":
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.type);
               if(item != null)
               {
                  result = item.name;
               }
               break;
            case "name":
               result = this.type;
               break;
            case "any":
         }
         return result;
      }
      
      public function getItemsList() : Array
      {
         var questInit:FarmQuestSettingsInit = null;
         var itemCodesInCategory:Array = null;
         var subTypeItems:Array = null;
         var itemCode:String = null;
         var categoryItem:FarmItem = null;
         var result:Array = new Array();
         questInit = QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
         var targetType:String = questInit.getTaskTargetType(this.action);
         switch(targetType)
         {
            case "category":
               itemCodesInCategory = questInit.getItemCodesInCategory(this.type);
               for each(itemCode in itemCodesInCategory)
               {
                  categoryItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  if(categoryItem != null)
                  {
                     result.push(categoryItem);
                  }
               }
               break;
            case "subtype":
               subTypeItems = Global.farmGameSettingsManager.getFarmItemsArrayByType(this.type,this.subtype,"",Global.worldManager.currentWorldType);
               result = subTypeItems;
               break;
            case "class":
               result = Global.farmGameSettingsManager.getFarmItemsArray(this.type.toLocaleLowerCase());
               if(result == null || result.length == 0)
               {
                  result = Global.farmGameSettingsManager.getFarmItemsArray("seed",this.type.toLocaleLowerCase());
               }
         }
         return result;
      }
      
      public function getActionKey() : String
      {
         return this.questName + "_" + this.type;
      }
      
      public function canAskForHelp() : Boolean
      {
         var result:Boolean = false;
         if(this.hasHelper())
         {
            result = this.helperAction.canPerform();
         }
         return result;
      }
      
      public function hasHelper() : Boolean
      {
         return this.helperAction != null;
      }
      
      public function shouldIgnore() : Boolean
      {
         var result:Boolean = false;
         if(this.m_extraData.ignore != null && this.m_extraData.ignore == "true")
         {
            result = true;
         }
         return result;
      }
      
      public function get rewards() : Vector.<Object>
      {
         return this.m_rewards;
      }
      
      public function set rewards(rewardsVector:Vector.<Object>) : void
      {
         this.m_rewards = rewardsVector;
      }
      
      public function doesRequireServerResponse() : Boolean
      {
         return (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).doesTaskTypeRequireServerSync(this.action);
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function get questPoints() : int
      {
         return this.m_points;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function set questPoints(points:int) : void
      {
         this.m_points = points;
      }
   }
}

