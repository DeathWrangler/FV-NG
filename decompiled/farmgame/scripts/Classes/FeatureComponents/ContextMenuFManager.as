package Classes.FeatureComponents
{
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.ContextMenuItem;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Managers.CaptureFeatureManager;
   import Managers.ExchangeManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureTrackingManager;
   import Managers.MFSRequestManager;
   import Managers.TimedSlotGiveawaysManager;
   import Widgets.Parser.XMLDialogParser;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GetMoreWaterWindow;
   import Widgets.Windows.Mastery.MasteryWindow;
   import Widgets.Windows.WishingFountainWindow;
   import ZLocalization.LocalizationObjectToken;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import mx.utils.ObjectUtil;
   
   public class ContextMenuFManager extends FeatureManager implements IContextMenuComponent
   {
      
      public static const MENU_GATE_NOTFULLYEXPANDED:String = "notFullyExpanded";
      
      public static const MENU_GATE_FULLYEXPANDED:String = "fullyExpanded";
      
      public static const MENU_GATE_FEATURE_EXPIRED:String = "featureExpired";
      
      public static const MENU_GATE_GIVEAWAY_EXPIRED:String = "giveawayExpired";
      
      public static const MENU_GATE_CUSTOM_HELPER:String = "customGate";
      
      public static const MENU_ACTION_ASKFORPARTS:String = "askForParts";
      
      public static const MENU_ACTION_ASKFORPARTS_MFS:String = "askForPartsMFS";
      
      public static const MENU_ACTION_ASK_FOR_CONTAINEE_PARTS:String = "askForContaineeParts";
      
      public static const MENU_ACTION_COMPLETENOW:String = "completeNow";
      
      public static const MENU_ACTION_LOOKINSIDE:String = "lookInside";
      
      public static const MENU_ACTION_CHOOSEVISUAL:String = "chooseVisual";
      
      public static const MENU_ACTION_SENDPARTS:String = "sendParts";
      
      public static const MENU_ACTION_UPGRADE:String = "upgrade";
      
      public static const MENU_ACTION_ASK_FOR_CREW:String = "askForCrew";
      
      public static const MENU_ACTION_ASK_FOR_DUCKS:String = "askForDucks";
      
      public static const MENU_ACTION_HARVEST_READY_NOW:String = "harvestReadyNow";
      
      public static const MENU_ACTION_LEARN_MORE:String = "learnMore";
      
      public static const MENU_ACTION_ASK_FOR_TREATS:String = "askForTreats";
      
      public static const MENU_ACTION_BUY_ITEM:String = "buyPart";
      
      public static const MENU_ACTION_OPEN_WHAT_IS_THIS:String = "whatIsThis";
      
      public static const MENU_ACTION_OPEN_MASTERY_WINDOW:String = "masteryWindow";
      
      public static const MENU_ACTION_CRAFT_FOUNTAIN:String = "craftFountain";
      
      public static const MENU_APPLY_ITEM:String = "applyItem";
      
      public static const MENU_ACTION_OPEN_GIVEAWAY:String = "openGiveaway";
      
      public static const MENU_ACTION_INSTANT_GROW:String = "instantGrow";
      
      public static const MENU_ACTION_BUY_WATER:String = "buyWater";
      
      public static const MENU_ACTION_OPEN_MARKET:String = "openMarket";
      
      public static const MENU_ACTION_OPEN_EXCLUSIVE_MARKET:String = "openExclusiveMarket";
      
      public static const MENU_ACTION_OPEN_TRADER:String = "openTrader";
      
      public static const MENU_ACTION_DISPLAY_POPUP:String = "displayPopup";
      
      public static const MENU_ACTION_CALL_STATIC_FUNCTION:String = "callStaticFunction";
      
      public static const ZLOC_LOOKUP_RETRY_INTERVAL:int = 100;
      
      public static const ZLOC_LOOKUP_RETRY_COUNT:int = 3;
      
      protected const URL_GIFTS:String = "gifts.php";
      
      private var m_menuItems:Array = new Array();
      
      private var ClassCompilingArray:Array = [SocialRaffleContextMenuDataHelper,SocialRaffleContextMenuFManager,CarnivalBoothContextMenuManager,CaptureFeatureLookInsideContextGate,AskForTreatsContextGate,AskForFeedContextGate,InstantGrowContextGate];
      
      public function ContextMenuFManager(owner:FeatureBuilding)
      {
         FarmStatsManager.sample(1000,"fv_fbml_depr_inspect","ContextMenuFManager","called");
         super(owner);
         this.populate();
      }
      
      private function populate(retryTimer:Timer = null) : void
      {
         var hasMenuItems:Boolean = false;
         var matchedMenuItems:Array = null;
         var unmatchedNames:Array = null;
         var i:int = 0;
         var featureData:BaseDataSource = null;
         var menuItemDataArray:Array = null;
         var menuItemData:BaseDataSource = null;
         var name:String = null;
         var experiment:String = null;
         var label:String = null;
         var menuItemDataObject:Object = null;
         var paramDataArray:Array = null;
         var paramObject:Object = null;
         var paramData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var contextFeature:XMLList = null;
         var menuItems:XMLList = null;
         var menuItem:XML = null;
         var nameString:String = null;
         var experimentName:String = null;
         var menuItemLabel:String = null;
         var menuItemObject:Object = null;
         var paramsObject:Object = null;
         var ownerItem:FarmItem = owner ? owner.getItem() : null;
         if(ownerItem)
         {
            hasMenuItems = false;
            matchedMenuItems = [];
            unmatchedNames = [];
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               featureData = ownerItem.getFeatureDataByName(FeatureManager.CONTEXT_MENU_FEATURE_NAME);
               if(featureData)
               {
                  menuItemDataArray = featureData.getArray("menuItem");
                  if(menuItemDataArray.length > 0)
                  {
                     hasMenuItems = true;
                     for each(menuItemData in menuItemDataArray)
                     {
                        name = menuItemData.getString("name");
                        experiment = menuItemData.getString("experiment");
                        label = ZLocUtils.t_pk(name);
                        if(label.length > 0)
                        {
                           menuItemDataObject = {
                              "label":label,
                              "action":menuItemData.getString("action"),
                              "gate":menuItemData.getString("gate"),
                              "gateHelper":menuItemData.getString("gateHelper"),
                              "dataHelper":menuItemData.getString("dataHelper"),
                              "showCash":menuItemData.getString("showCash"),
                              "zLocName":name
                           };
                           paramDataArray = menuItemData.getArray("param");
                           if(paramDataArray.length > 0)
                           {
                              paramObject = {};
                              for each(paramData in paramDataArray)
                              {
                                 paramObject[paramData.getString("name")] = paramData.getString("value");
                              }
                              menuItemDataObject.params = paramObject;
                           }
                           if(experiment.length > 0)
                           {
                              menuItemDataObject.experiment = experiment;
                           }
                           matchedMenuItems.push(menuItemDataObject);
                        }
                        else
                        {
                           unmatchedNames.push(name);
                           FarmStatsManager.sample(100,"ContextMenuLabelFailure",ownerItem.name + "_feature",nameString);
                        }
                     }
                  }
               }
            }
            else
            {
               featuresXML = ownerItem.getFeaturesXML();
               if(featuresXML)
               {
                  contextFeature = featuresXML.(@name == FeatureManager.CONTEXT_MENU_FEATURE_NAME);
                  if(contextFeature)
                  {
                     menuItems = contextFeature.menuItem;
                     if(menuItems)
                     {
                        hasMenuItems = true;
                        for each(menuItem in menuItems)
                        {
                           nameString = menuItem.@name;
                           experimentName = String(menuItem.@experiment);
                           menuItemLabel = ZLocUtils.t_pk(nameString);
                           if(menuItemLabel.length > 0)
                           {
                              menuItemObject = {
                                 "label":menuItemLabel,
                                 "action":String(menuItem.@action),
                                 "gate":String(menuItem.@gate),
                                 "gateHelper":String(menuItem.@gateHelper),
                                 "dataHelper":String(menuItem.@dataHelper),
                                 "showCash":String(menuItem.@showCash),
                                 "zLocName":nameString
                              };
                              paramsObject = XMLDialogParser.getNameValueParamsFromNode(menuItem);
                              if(Classes.util.ObjectUtil.objectHasProperties(paramsObject))
                              {
                                 menuItemObject["params"] = paramsObject;
                              }
                              if(experimentName != "")
                              {
                                 menuItemObject["experiment"] = experimentName;
                              }
                              matchedMenuItems.push(menuItemObject);
                           }
                           else
                           {
                              unmatchedNames.push(nameString);
                              FarmStatsManager.sample(100,"ContextMenuLabelFailure",ownerItem.name + "_feature",nameString);
                           }
                        }
                     }
                  }
               }
            }
            if(hasMenuItems && unmatchedNames.length > 0)
            {
               if(retryTimer == null)
               {
                  retryTimer = new Timer(ZLOC_LOOKUP_RETRY_INTERVAL,ZLOC_LOOKUP_RETRY_COUNT);
                  retryTimer.addEventListener(TimerEvent.TIMER,this.onPopulateTimeout);
                  retryTimer.start();
                  FarmStatsManager.sample(1000,"ContextMenuLabelFailureRetry",ownerItem.name + "_feature","retryTimerBegin");
               }
               for(i = 0; i < unmatchedNames.length; i++)
               {
                  FarmStatsManager.sample(1000,"ContextMenuLabelFailureRetry",ownerItem.name + "_feature",unmatchedNames[i],"retryFailure_" + retryTimer.currentCount);
               }
            }
            else
            {
               this.m_menuItems = this.m_menuItems.concat(matchedMenuItems);
               if(retryTimer != null)
               {
                  for(i = 0; i < matchedMenuItems.length; i++)
                  {
                     FarmStatsManager.sample(1000,"ContextMenuLabelFailureRetry",ownerItem.name + "_feature",matchedMenuItems[i].zLocName,"retrySuccess_" + retryTimer.currentCount);
                  }
                  retryTimer.stop();
               }
            }
         }
         else
         {
            GlobalEngine.error("ContextMenuFManager","getItem returned null");
            if(retryTimer)
            {
               retryTimer.stop();
               retryTimer.removeEventListener(TimerEvent.TIMER,this.onPopulateTimeout);
            }
         }
      }
      
      private function onPopulateTimeout(e:TimerEvent) : void
      {
         this.populate(Timer(e.target));
      }
      
      public function appendMenuItems(menuItems:Array) : Array
      {
         var menuItem:Object = null;
         for each(menuItem in this.m_menuItems)
         {
            if(this.checkMenuItemGate(menuItem))
            {
               this.modifyMenuItem(menuItem);
               menuItems.push(menuItem);
            }
         }
         return menuItems;
      }
      
      protected function modifyMenuItem(menuItem:Object) : void
      {
         var quantity:Number = NaN;
         var partItem:FarmItem = null;
         var partName:LocalizationObjectToken = null;
         if(menuItem.showCash == "true")
         {
            quantity = -1;
            switch(menuItem.action)
            {
               case MENU_ACTION_COMPLETENOW:
                  quantity = owner.nextExpansionCashNeeded();
                  break;
               case MENU_ACTION_HARVEST_READY_NOW:
                  quantity = owner.getHarvestReadyNowCashPrice();
            }
            if(quantity != -1)
            {
               menuItem["label"] = ZLocUtils.t_pk(menuItem.zLocName,"",{"quantity":quantity});
            }
         }
         if(menuItem.action == MENU_ACTION_ASK_FOR_CONTAINEE_PARTS)
         {
            if(Boolean(owner.containeeManager) && Boolean(owner.containeeManager.firstContaineePart))
            {
               partItem = Global.farmGameSettingsManager.getFarmItemByName(owner.containeeManager.firstContaineePart);
               partName = ZLocUtils.tk_pk(partItem.friendlyName);
               menuItem["label"] = ZLocUtils.t_pk(menuItem.zLocName,"",{"partName":partName});
            }
         }
      }
      
      protected function checkMenuItemGate(menuItem:Object) : Boolean
      {
         var gate:String = null;
         var helper:ContextMenuGateHelper = null;
         var limitedEndTimestamp:Number = NaN;
         var result:Boolean = true;
         if(menuItem.experiment != null && Global.experimentManager.getExperimentVariant(menuItem.experiment) == 0)
         {
            result = false;
         }
         else if(menuItem.gate.length > 0)
         {
            for each(gate in (menuItem.gate as String).split(","))
            {
               switch(gate)
               {
                  case MENU_GATE_NOTFULLYEXPANDED:
                     if(owner.hasReachedMaxExpansionLevel() || owner.isNextStageRegionLocked())
                     {
                        result = false;
                     }
                     break;
                  case MENU_GATE_FULLYEXPANDED:
                     if(!owner.hasReachedMaxExpansionLevel())
                     {
                        result = false;
                     }
                     break;
                  case MENU_GATE_FEATURE_EXPIRED:
                     if(menuItem.dataHelper != null && menuItem.dataHelper != "")
                     {
                        limitedEndTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(menuItem.dataHelper);
                        if(limitedEndTimestamp < GlobalEngine.serverTime)
                        {
                           result = false;
                        }
                     }
                     break;
                  case MENU_GATE_CUSTOM_HELPER:
                     helper = this.getGateHelper(menuItem.action);
                     result = helper.shouldDisplay();
                     break;
                  case MENU_GATE_GIVEAWAY_EXPIRED:
                     if(menuItem.dataHelper != null && menuItem.dataHelper != "")
                     {
                        result = TimedSlotGiveawaysManager.validGiveaway(String(menuItem.dataHelper));
                     }
               }
            }
         }
         return result;
      }
      
      public function getDataHelper(action:String) : IContextMenuDataHelper
      {
         var featureClassName:String = null;
         var managerClass:Class = null;
         var menuItem:Object = this.getMenuItemData(action);
         var dataHelper:IContextMenuDataHelper = null;
         if(menuItem != null && menuItem.dataHelper != null && menuItem.dataHelper != "")
         {
            try
            {
               featureClassName = menuItem.dataHelper;
               managerClass = getDefinitionByName("Classes.FeatureComponents." + featureClassName) as Class;
               dataHelper = new managerClass();
            }
            catch(e:ReferenceError)
            {
            }
         }
         return dataHelper;
      }
      
      public function getGateHelper(action:String) : ContextMenuGateHelper
      {
         var featureClassName:String = null;
         var gateClass:Class = null;
         var menuItem:Object = this.getMenuItemData(action);
         var dataHelper:ContextMenuGateHelper = null;
         if(menuItem != null && menuItem.gateHelper != null && menuItem.gateHelper != "")
         {
            try
            {
               featureClassName = menuItem.gateHelper;
               gateClass = getDefinitionByName("Classes.FeatureComponents." + featureClassName) as Class;
               dataHelper = new gateClass(owner);
            }
            catch(e:ReferenceError)
            {
            }
         }
         return dataHelper;
      }
      
      private function getMenuItemData(action:String) : Object
      {
         var menuItem:Object = null;
         var menuData:Object = {};
         for each(menuItem in this.m_menuItems)
         {
            if(Boolean(menuItem) && menuItem.action == action)
            {
               menuData = menuItem;
               break;
            }
         }
         return menuData;
      }
      
      public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var dataHelper:IContextMenuDataHelper = null;
         var menuEntry:Object = null;
         var giveawayEntry:Object = null;
         var itemsEntry:Object = null;
         var exclusiveItemsEntry:Object = null;
         var traderEntry:Object = null;
         var instantGrow:InstantGrowFManager = null;
         var mostNeededItemName:String = null;
         var buildingItem:BuildingItem = null;
         var extraData:Object = null;
         var featureName:String = null;
         var friendSetCode:String = null;
         var currentFriendSet:Number = NaN;
         var itemName:String = null;
         var windowClassName:String = null;
         var windowClass:Class = null;
         var learnMoreWindow:FarmWindow = null;
         var neededItemName:String = null;
         var applyItem:String = null;
         var itemsList:String = null;
         var exclusiveItemsList:String = null;
         var traderName:String = null;
         var classDefinition:Class = null;
         var staticFunction:String = null;
         var params:Object = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MENU_ACTION_ASKFORPARTS:
                  Global.farmSocialNetwork.farmRedirect(this.URL_GIFTS + "?template=wishlist&ref=" + owner.getItem().name,null,"_blank");
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_aksforparts");
                  break;
               case MENU_ACTION_ASK_FOR_DUCKS:
                  Global.farmSocialNetwork.farmRedirect(this.URL_GIFTS + "?template=wishlist&ref=duck",null,"_blank");
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_aksforparts");
                  break;
               case MENU_ACTION_ASKFORPARTS_MFS:
                  if(owner.getMostNeededItem())
                  {
                     mostNeededItemName = owner.getMostNeededItem().item.name;
                     MFSRequestManager.getInstance().makeAskMatsRequest(owner.getItem().name,mostNeededItemName,"","",MFSConstants.SOURCE_CONTEXT_MENU,owner.getItem().name + "_feature","context_menu","context_aksforpartsmfs");
                     buildingItem = owner.getItem() as BuildingItem;
                     if(buildingItem)
                     {
                        FeatureTrackingManager.instance.sendR4R(buildingItem.buildingName);
                     }
                  }
                  break;
               case MENU_ACTION_COMPLETENOW:
                  owner.beginCompleteExpansionFlow(FeatureBuilding.ACTION_SOURCE_CONTEXT_MENU);
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_completenow");
                  break;
               case MENU_ACTION_LOOKINSIDE:
                  owner.displayStorageDialog();
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_lookinside");
                  break;
               case MENU_ACTION_CHOOSEVISUAL:
                  owner.displayStorageDialog(FeatureBuilding.CHOOSEVISUAL_ACTION);
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_choosevisual");
                  break;
               case MENU_ACTION_SENDPARTS:
                  UI.displayPopup(new CustomFreeGiftSelectionWindow(owner.getPartsArray()));
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_send");
                  break;
               case MENU_ACTION_CRAFT_FOUNTAIN:
                  WishingFountainWindow.openMakeRecipeWindow(owner.getItem().name);
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_craft");
                  break;
               case MENU_ACTION_UPGRADE:
                  if(owner.upgrader)
                  {
                     owner.upgrader.upgrade();
                  }
                  break;
               case MENU_ACTION_ASK_FOR_CREW:
                  dataHelper = this.getDataHelper(item.action);
                  if(dataHelper != null)
                  {
                     extraData = dataHelper.getData(item.action);
                     featureName = extraData.featureName;
                     friendSetCode = extraData.friendSetCode;
                     currentFriendSet = Number(extraData.currentFriendSet);
                     itemName = extraData.itemName;
                     MFSRequestManager.getInstance().makeFriendSetRequest(itemName,featureName,friendSetCode,currentFriendSet,MFSConstants.SOURCE_CONTEXT_MENU,owner.getItem().name + "_feature","context_menu","context_ask_for_crew");
                  }
                  break;
               case MENU_ACTION_LEARN_MORE:
                  menuEntry = this.getSpecificEntry(MENU_ACTION_LEARN_MORE);
                  if(menuEntry.hasOwnProperty("dataHelper") && menuEntry.dataHelper != "")
                  {
                     windowClassName = menuEntry.dataHelper as String;
                     try
                     {
                        windowClass = getDefinitionByName(windowClassName) as Class;
                        learnMoreWindow = new windowClass();
                        FarmStatsManager.count(owner.getItem().name,"learnMore");
                        UI.displayPopup(learnMoreWindow);
                     }
                     catch(err:Error)
                     {
                        ErrorManager.addError("Error instantiating " + windowClassName + ". " + err.message);
                     }
                  }
                  break;
               case MENU_ACTION_HARVEST_READY_NOW:
                  if(!owner.isHarvestable())
                  {
                     owner.frictionlessHarvestReadyNow(null);
                     FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_instaharvest");
                  }
                  break;
               case MENU_ACTION_ASK_FOR_TREATS:
                  FarmStatsManager.count(owner.getItem().name,"context_menu","ask_treats");
                  CaptureFeatureManager.instance.askForTreats(owner.featureName,"context");
                  break;
               case MENU_ACTION_BUY_ITEM:
                  if(owner.getMostNeededItem())
                  {
                     neededItemName = owner.getMostNeededItem().item.name;
                     UI.displayMiniMarketDialog([neededItemName],owner.getItemName(),owner.getTypeName());
                  }
                  break;
               case MENU_ACTION_OPEN_WHAT_IS_THIS:
                  FarmStatsManager.count(owner.getItem().name,"context_menu","what_is_this");
                  TutorialUI.displayBuildingTutorialWindow(this.m_owner,m_owner.getItem().prefixUrl);
                  break;
               case MENU_ACTION_OPEN_MASTERY_WINDOW:
                  FarmStatsManager.count(owner.getItem().name,"context_menu","mastery_window","animal");
                  UI.displayPopup(new MasteryWindow(MasteryWindow.TYPE_ANIMAL));
                  break;
               case MENU_APPLY_ITEM:
                  if(owner.getMostNeededItem())
                  {
                     applyItem = owner.getMostNeededItem().item.name;
                     owner.onApplyMaxPossibleBuildingParts(applyItem,new Array(applyItem),false);
                  }
                  break;
               case MENU_ACTION_ASK_FOR_CONTAINEE_PARTS:
                  FarmStatsManager.count(owner.getItem().name,"context_menu","ask_for_containee_part");
                  if(Boolean(owner.containeeManager) && Boolean(owner.containeeManager.firstContaineePart))
                  {
                     MFSRequestManager.getInstance().makeAskMatsRequest(owner.getItem().name,owner.containeeManager.firstContaineePart,owner.getItem().name,"",MFSConstants.SOURCE_CONTEXT_MENU);
                  }
                  break;
               case MENU_ACTION_OPEN_GIVEAWAY:
                  giveawayEntry = this.getSpecificEntry(MENU_ACTION_OPEN_GIVEAWAY);
                  if(giveawayEntry.hasOwnProperty("dataHelper") && giveawayEntry.dataHelper != "")
                  {
                     StatsManager.count("TimedGiveaway",String(giveawayEntry.dataHelper),"building","open_giveaway");
                     TimedSlotGiveawaysManager.showGiveawayWindow(String(giveawayEntry.dataHelper));
                  }
                  break;
               case MENU_ACTION_OPEN_MARKET:
                  itemsEntry = this.getSpecificEntry(MENU_ACTION_OPEN_MARKET);
                  if(itemsEntry != null && itemsEntry.dataHelper != null)
                  {
                     itemsList = itemsEntry.dataHelper as String;
                     if(itemsList != null)
                     {
                        UI.displayMiniMarketDialog(itemsList.split(","),UI.MARKET_CONTEXT_UNKNOWN,"",null,true,false,false,true);
                     }
                  }
                  break;
               case MENU_ACTION_OPEN_EXCLUSIVE_MARKET:
                  exclusiveItemsEntry = this.getSpecificEntry(MENU_ACTION_OPEN_EXCLUSIVE_MARKET);
                  if(exclusiveItemsEntry != null && exclusiveItemsEntry.dataHelper != null)
                  {
                     exclusiveItemsList = exclusiveItemsEntry.dataHelper as String;
                     if(exclusiveItemsList != null)
                     {
                        UI.displayMiniMarketDialog(exclusiveItemsList.split(","),UI.MINIMARKET_CONTEXT_CHARITY,"",null,true,false,false,false,owner.featureName,true);
                     }
                  }
                  break;
               case MENU_ACTION_OPEN_TRADER:
                  traderEntry = this.getSpecificEntry(MENU_ACTION_OPEN_TRADER);
                  if(traderEntry.hasOwnProperty("dataHelper") && traderEntry.dataHelper != "")
                  {
                     traderName = String(traderEntry.dataHelper);
                     StatsManager.count(ExchangeManager.STATS_COUNTER,traderName,"building","open_trader");
                     ExchangeManager.getInstance().openWindow(traderName);
                  }
                  break;
               case MENU_ACTION_DISPLAY_POPUP:
                  owner.displayDialog("storage",item.params);
                  StatsManager.count(owner.getItem().name,StatsTrackingConstants.LOOK_INSIDE);
                  break;
               case MENU_ACTION_INSTANT_GROW:
                  instantGrow = owner.instantGrow;
                  if(instantGrow)
                  {
                     instantGrow.promptForInstantGrow();
                  }
                  break;
               case MENU_ACTION_BUY_WATER:
                  UI.displayPopup(new GetMoreWaterWindow());
                  break;
               case MENU_ACTION_CALL_STATIC_FUNCTION:
                  if(Boolean(item.params) && Boolean(item.params.className) && Boolean(item.params.func))
                  {
                     classDefinition = null;
                     try
                     {
                        classDefinition = getDefinitionByName(item.params.className) as Class;
                     }
                     catch(e:Error)
                     {
                        ErrorManager.addError(ErrorManager.getFormattedErrorMessage("Could not create class definition from class path. ","classPath=" + item.params.className));
                     }
                     staticFunction = item.params.func;
                     if(Boolean(classDefinition) && Boolean(staticFunction) && Boolean(classDefinition[staticFunction]))
                     {
                        params = mx.utils.ObjectUtil.clone(item.params);
                        delete params.className;
                        delete params.func;
                        if(Classes.util.ObjectUtil.objectHasProperties(params))
                        {
                           classDefinition[staticFunction](params);
                        }
                        else
                        {
                           classDefinition[staticFunction]();
                        }
                     }
                  }
            }
         }
      }
      
      public function getSpecificEntry(action:String, gate:String = null) : Object
      {
         var result:Object = null;
         for(var i:int = 0; i < this.m_menuItems.length; i++)
         {
            if(this.m_menuItems[i].action == action && (gate == null || this.m_menuItems[i].gate == gate))
            {
               result = this.m_menuItems[i];
               break;
            }
         }
         return result;
      }
   }
}

