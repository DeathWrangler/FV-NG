package Managers
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CompletionPack.BuildableCompletionPackIntermediateWindow;
   import Widgets.Windows.CompletionPack.BuildableCompletionPackRewardWindow;
   import Widgets.Windows.CompletionPack.BuildableCompletionPackWindow;
   
   public class BuildableCompletionPackagesManager
   {
      
      private static var m_instance:BuildableCompletionPackagesManager = null;
      
      public static const OPTION_PREFIX:String = "option_";
      
      public static const OPTION_1:String = "option_1";
      
      public static const OPTION_2:String = "option_2";
      
      public static const OPTION_3:String = "option_3";
      
      public static const OPTION_4:String = "option_4";
      
      private static const FREQUENCY_TO_SHOW_DAYS:int = 2;
      
      private static const MAX_SEEN_COUNT:int = 2;
      
      private static const OVERRIDE_MAX_SEEN_COUNT:int = 3;
      
      private static const PACKAGES_INFO:Array = [{
         "name":"option_1",
         "title":"option_1_candy_title",
         "subtext":"option_1_candy_subtext",
         "originalCost":"275",
         "image":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xcw_CompletePackageCard_1.png",
         "rewardImage":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xac_CompletePackage1_200.png"
      },{
         "name":"option_2",
         "title":"option_2_candy_title",
         "subtext":"option_2_candy_subtext",
         "originalCost":"646",
         "image":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xcw_CompletePackageCard_2.png",
         "rewardImage":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xac_CompletePackage2_200.png"
      },{
         "name":"option_3",
         "title":"option_3_candy_title",
         "subtext":"option_3_candy_subtext",
         "originalCost":"921",
         "image":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xcw_CompletePackageCard_3.png",
         "rewardImage":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xac_CompletePackage3_200.png"
      },{
         "name":"option_4",
         "title":"option_4_candy_title",
         "subtext":"option_4_candy_subtext",
         "originalCost":"1171",
         "image":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xcw_CompletePackageCard_4.png",
         "rewardImage":"assets/dialogs/4d_elements/xcw_completionpacks/FV_xac_CompletePackage4_200.png"
      }];
      
      public static const INTERMEDIATE_WINDOW_STAT:String = "MOTD_CANDY_COMPLETION_PACK";
      
      public static const MAIN_WINDOW_STAT:String = "DIALOG_CANDY_COMPLETION_PACK";
      
      public static const HUD_ICON_STAT:String = "HUD_CANDY_COMPLETION_PACK";
      
      public static const REWARD_DIALOG_STAT:String = "REWARD_CANDY_COMPLETION_PACK";
      
      private static const UNWITHER_RING_ITEM_NAME:String = "xcwunwitherringbox";
      
      private static const BUILDABLE_1_CODE:String = "XJk";
      
      private static const BUILDABLE_2_CODE:String = "TdR";
      
      public static const ICON_TYPE_COMPLETION_PACK:String = "xcw_completionPack";
      
      public static const COMPLETION_PACK_BOUGHT:String = "xcw_completionPackBought";
      
      public static const COMPLETION_PACK_FEATURE_NAME:String = "xcw_completion_pack";
      
      public static const COMPLETION_PACK_WORLD:String = "candy";
      
      private static const QUEST_NAMES:Array = ["xcw_eversweettree-01-001","xcw_eversweettree-01-002","xcw_eversweettree-01-003","xcw_eversweettree-01-004","xcw_eversweettree-01-005"];
      
      public static const XAU_INTERMEDIATE_WINDOW_STAT:String = "MOTD_AUSTRALIA_COMPLETION_PACK";
      
      public static const XAU_MAIN_WINDOW_STAT:String = "DIALOG_AUSTRALIA_COMPLETION_PACK";
      
      public static const XAU_HUD_ICON_STAT:String = "HUD_AUSTRALIA_COMPLETION_PACK";
      
      public static const XAU_REWARD_DIALOG_STAT:String = "Reward_Dialog";
      
      private static const xau_packagesInfo:Array = [{
         "name":"option_1",
         "title":"option_1_title",
         "subtext":"option_1_subtext",
         "originalCost":"515",
         "image":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack1_100.png",
         "rewardImage":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack1.png"
      },{
         "name":"option_2",
         "title":"option_2_title",
         "subtext":"option_2_subtext",
         "originalCost":"2232",
         "image":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack2_100.png",
         "rewardImage":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack2.png"
      },{
         "name":"option_3",
         "title":"option_3_title",
         "subtext":"option_3_subtext",
         "originalCost":"2747",
         "image":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack3_100.png",
         "rewardImage":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack3.png"
      },{
         "name":"option_4",
         "title":"option_4_title",
         "subtext":"option_4_subtext",
         "originalCost":"2997",
         "image":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack4_100.png",
         "rewardImage":"assets/dialogs/4d_elements/xau_completionpacks/xau_completionpack_pack4.png"
      }];
      
      private static const XAU_UNWITHER_RING_ITEM_NAME:String = "xauunwitherringbox";
      
      private static const XAU_BUILDABLE_1_CODE:String = "era";
      
      private static const XAU_BUILDABLE_2_CODE:String = "ftS";
      
      public static const XAU_ICON_TYPE_COMPLETION_PACK:String = "completionPack";
      
      public static const XAU_COMPLETION_PACK_BOUGHT:String = "completionPackBought";
      
      public static const XAU_COMPLETION_PACK_FEATURE_NAME:String = "xau_completion_pack";
      
      public static const XAU_COMPLETION_PACK_WORLD:String = "australia";
      
      private var m_optionsInfo:Array = new Array();
      
      public function BuildableCompletionPackagesManager()
      {
         super();
      }
      
      public static function getInstance() : BuildableCompletionPackagesManager
      {
         if(m_instance == null)
         {
            m_instance = new BuildableCompletionPackagesManager();
         }
         return m_instance;
      }
      
      public static function getBuildableCompletionPackages() : void
      {
         var currentTimeSeconds:int = 0;
         var endDate:String = null;
         var endTimeSeconds:int = 0;
         if(!Global.player.getSeenFlag(COMPLETION_PACK_BOUGHT))
         {
            currentTimeSeconds = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            endDate = Global.flashHotParams["COMPLETION_PACK_END_DATE"];
            endTimeSeconds = 0;
            if(endDate != "")
            {
               endTimeSeconds = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND);
            }
            if(currentTimeSeconds < endTimeSeconds)
            {
               TransactionManager.addTransaction(new TGenericTransaction("BuildableCompletionPackagesService","getBuildableCompletionInfo",onComplete));
            }
         }
      }
      
      private static function onComplete(result:Object) : void
      {
         var optionsInfo:Array = null;
         var i:int = 0;
         var manager:BuildableCompletionPackagesManager = null;
         var currentIndex:int = 0;
         var option:Object = null;
         var currentCount:int = 0;
         var intermidateWindow:BuildableCompletionPackIntermediateWindow = null;
         if(result)
         {
            if(result.hasOwnProperty("completed"))
            {
               if(result.completed == false && result.hasOwnProperty("option_1") && result.hasOwnProperty("option_2") && result.hasOwnProperty("option_3") && result.hasOwnProperty("option_4"))
               {
                  optionsInfo = new Array();
                  for(i = 1; i <= 4; i++)
                  {
                     currentIndex = i - 1;
                     option = new Object();
                     option.name = OPTION_PREFIX + i;
                     option.cost = result[OPTION_PREFIX + i];
                     option.title = PACKAGES_INFO[currentIndex].title;
                     option.subtext = PACKAGES_INFO[currentIndex].subtext;
                     option.image = PACKAGES_INFO[currentIndex].image;
                     option.rewardImage = PACKAGES_INFO[currentIndex].rewardImage;
                     option.originalCost = PACKAGES_INFO[currentIndex].originalCost;
                     optionsInfo.push(option);
                  }
                  manager = BuildableCompletionPackagesManager.getInstance();
                  manager.setOptionsInfo(optionsInfo);
                  Global.hud.rightSideIconQueue.addIcon(ICON_TYPE_COMPLETION_PACK,DynamicIconQueue.ADD_BY_PRIORITY,null,false);
                  FarmStatsManager.count("HUD","impressions",HUD_ICON_STAT);
                  if(manager.shouldShowIntermediateWindow())
                  {
                     currentCount = Global.player.getActionCount(COMPLETION_PACK_FEATURE_NAME);
                     currentCount++;
                     Global.player.setActionCount(COMPLETION_PACK_FEATURE_NAME,currentCount,true);
                     intermidateWindow = new BuildableCompletionPackIntermediateWindow(optionsInfo);
                     UI.displayPopup(intermidateWindow);
                  }
               }
            }
         }
      }
      
      private function shouldShowIntermediateWindow() : Boolean
      {
         var shouldShow:Boolean = false;
         var lastTimeSeenWindow:int = Global.player.getFeatureLastShown(COMPLETION_PACK_FEATURE_NAME);
         var currentTimeSeconds:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var frequencyToShowSeconds:int = FREQUENCY_TO_SHOW_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
         var overrideDate:String = Global.flashHotParams["COMPLETION_PACK_OVERRIDE_POPUP_DATE"];
         var overrideTimeSeconds:int = 0;
         if(overrideDate != "")
         {
            overrideTimeSeconds = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(overrideDate) / FarmGameUtil.NUM_MSECS_IN_SECOND);
         }
         var isOverride:Boolean = overrideTimeSeconds > currentTimeSeconds;
         var maxCount:int = -1;
         if(isOverride)
         {
            maxCount = OVERRIDE_MAX_SEEN_COUNT;
         }
         else if(currentTimeSeconds - lastTimeSeenWindow >= frequencyToShowSeconds)
         {
            maxCount = MAX_SEEN_COUNT;
         }
         var currentSeenCount:int = Global.player.getActionCount(COMPLETION_PACK_FEATURE_NAME);
         if(currentSeenCount < maxCount)
         {
            shouldShow = true;
         }
         return shouldShow;
      }
      
      private function setOptionsInfo(optionsInfo:Array) : void
      {
         this.m_optionsInfo = optionsInfo;
      }
      
      private function getOptionsInfo() : Array
      {
         return this.m_optionsInfo;
      }
      
      public function displayMainWindow() : void
      {
         var window:BuildableCompletionPackWindow = new BuildableCompletionPackWindow(this.getOptionsInfo());
         UI.displayPopup(window);
      }
      
      public function completeBuildingByOption(optionName:String) : void
      {
         var buildable1:FarmItem = null;
         var buildable2:FarmItem = null;
         TransactionManager.addTransaction(new TGenericTransaction("BuildableCompletionPackagesService","completeBuildables",null,[optionName]));
         var isInCompletionPackWorld:Boolean = Global.worldManager.currentWorldType == COMPLETION_PACK_WORLD;
         var buildingsText:String = "";
         var optionIcon:String = "";
         var rewardNames:Array = null;
         if(isInCompletionPackWorld)
         {
            switch(optionName)
            {
               case OPTION_1:
                  buildingsText = this.completeSpecificBuilding(BUILDABLE_1_CODE);
                  optionIcon = PACKAGES_INFO[0].rewardImage;
                  break;
               case OPTION_2:
                  buildingsText = this.completeSpecificBuilding(BUILDABLE_2_CODE);
                  optionIcon = PACKAGES_INFO[1].rewardImage;
                  break;
               case OPTION_3:
                  buildingsText = this.completeSpecificBuilding(BUILDABLE_1_CODE);
                  buildingsText += " and ";
                  buildingsText += this.completeSpecificBuilding(BUILDABLE_2_CODE);
                  optionIcon = PACKAGES_INFO[2].rewardImage;
                  break;
               case OPTION_4:
                  buildingsText = this.completeSpecificBuilding(BUILDABLE_1_CODE);
                  buildingsText += " and ";
                  buildingsText += this.completeSpecificBuilding(BUILDABLE_2_CODE);
                  optionIcon = PACKAGES_INFO[3].rewardImage;
                  Global.player.addGift(UNWITHER_RING_ITEM_NAME);
            }
         }
         else
         {
            buildable1 = null;
            buildable2 = null;
            switch(optionName)
            {
               case OPTION_1:
                  buildable1 = Global.farmGameSettingsManager.getFarmItemByCode(BUILDABLE_1_CODE);
                  buildingsText = buildable1.friendlyTitle;
                  optionIcon = PACKAGES_INFO[0].rewardImage;
                  break;
               case OPTION_2:
                  buildable2 = Global.farmGameSettingsManager.getFarmItemByCode(BUILDABLE_2_CODE);
                  buildingsText = buildable2.friendlyTitle;
                  optionIcon = PACKAGES_INFO[1].rewardImage;
                  break;
               case OPTION_3:
                  buildable1 = Global.farmGameSettingsManager.getFarmItemByCode(BUILDABLE_1_CODE);
                  buildable2 = Global.farmGameSettingsManager.getFarmItemByCode(BUILDABLE_2_CODE);
                  buildingsText = buildable1.friendlyTitle + " and " + buildable2.friendlyTitle;
                  optionIcon = PACKAGES_INFO[2].rewardImage;
                  break;
               case OPTION_4:
                  buildable1 = Global.farmGameSettingsManager.getFarmItemByCode(BUILDABLE_1_CODE);
                  buildable2 = Global.farmGameSettingsManager.getFarmItemByCode(BUILDABLE_2_CODE);
                  buildingsText = buildable1.friendlyTitle + " and " + buildable2.friendlyTitle;
                  optionIcon = PACKAGES_INFO[3].rewardImage;
                  Global.player.addGift(UNWITHER_RING_ITEM_NAME);
            }
         }
         if(optionName != OPTION_2)
         {
            rewardNames = this.completeQuestLine();
         }
         var rewardWindow:BuildableCompletionPackRewardWindow = new BuildableCompletionPackRewardWindow(optionName,isInCompletionPackWorld,buildingsText,optionIcon,rewardNames);
         UI.displayPopup(rewardWindow);
      }
      
      private function completeSpecificBuilding(buildableCode:String) : String
      {
         var buildable:StorageBuilding = null;
         var buildableText:String = "";
         var objectsInWorld:Array = Global.world.getObjectsByCode(buildableCode);
         if(objectsInWorld.length == 1)
         {
            if(objectsInWorld[0] is StorageBuilding)
            {
               buildable = objectsInWorld[0] as StorageBuilding;
               buildable.completeBuildable();
               buildableText = ZLocUtils.tk_pk_asTitle(buildable.getItemFriendlyName());
            }
         }
         return buildableText;
      }
      
      private function completeQuestLine() : Array
      {
         var task:FarmTask = null;
         var reward:Object = null;
         var questNameCount:int = int(QUEST_NAMES.length);
         var farmQuestSettingsInitInstance:FarmQuestSettingsInit = FarmQuestSettingsInit.getInstance();
         var farmQuestManager:FarmQuestManager = FarmQuestManager.getInstance();
         var farmQuest:FarmQuest = null;
         var rewardNames:Array = new Array();
         var questName:String = "";
         var tasks:Vector.<FarmTask> = null;
         var questRewards:Vector.<Object> = null;
         var quantity:int = 0;
         var rewardItem:FarmItem = null;
         for(var i:int = 0; i < questNameCount; i++)
         {
            questName = QUEST_NAMES[i];
            if(!farmQuestManager.isQuestComplete(questName))
            {
               farmQuest = farmQuestSettingsInitInstance.getItemByName(questName) as FarmQuest;
               if(farmQuest)
               {
                  tasks = farmQuest.farmTasks;
                  questRewards = farmQuest.farmRewards;
                  if(questRewards)
                  {
                     for each(reward in questRewards)
                     {
                        if(Boolean(reward.value) && reward.type == QuestConstants.REWARD_GRANT_ITEM)
                        {
                           rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                           if(rewardItem)
                           {
                              quantity = 1;
                              if(reward.quantity)
                              {
                                 quantity = int(reward.quantity);
                              }
                              Global.player.addGift(rewardItem.name,"0",quantity);
                              rewardNames.push(rewardItem.friendlyTitle);
                           }
                        }
                     }
                  }
                  for each(task in tasks)
                  {
                     task.markComplete();
                  }
                  FarmQuestManager.getInstance().removeActiveQuestByName(questName);
                  if(farmQuest.children.length == 0)
                  {
                     farmQuest.removeIconFromIconQueue();
                  }
               }
            }
         }
         return rewardNames;
      }
      
      public function travelToBuildablesCompletionPackWorld() : void
      {
         var shouldFreezeFarm:Boolean = Boolean(Global.player.options.shouldFreezeFarm);
         Global.worldManager.swapFarm(COMPLETION_PACK_WORLD,shouldFreezeFarm);
      }
   }
}

