package Widgets.Windows.Orchards
{
   import Classes.Constants.Experiments;
   import Classes.OrchardFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Frames.Orchards.OrchardFeatureBuildingSlotFrame;
   import Widgets.Windows.Mastery.MasteryWindow;
   import Widgets.Windows.StorageContentsWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class OrchardFeatureBuildingManagementWindow extends StorageContentsWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_OrchardsManage2.swf";
      
      private static const ASK_FOR_TREES_URL:String = "gifts.php?template=wishlist&ref=orchard";
      
      private static const m_excludeMiniMarketItems:Array = ["pkg_arborists","wateringcan"];
      
      private var m_orchardBuilding:OrchardFeatureBuilding;
      
      private var m_buildingName:String;
      
      public function OrchardFeatureBuildingManagementWindow(orchardBuilding:OrchardFeatureBuilding, buildingName:String = null)
      {
         super(orchardBuilding);
         this.m_orchardBuilding = orchardBuilding;
         if(buildingName)
         {
            this.m_buildingName = buildingName;
         }
         else if(this.m_orchardBuilding.bldgName)
         {
            this.m_buildingName = this.m_orchardBuilding.bldgName;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var expandGroup:ZwFrame = null;
         var currentWorld:String = Global.worldManager.currentWorldType;
         var titleKey:String = "OrchardDialog_Title";
         var subHeaderKey:String = "OrchardDialog_Subheader";
         if(Boolean(this.m_buildingName) && this.m_buildingName != "")
         {
            titleKey = ZLocUtils.getExistingLocalizationKey("Dialogs",currentWorld + "_" + titleKey,titleKey);
            subHeaderKey = ZLocUtils.getExistingLocalizationKey("Dialogs",this.m_buildingName + "Dialog_Subheader",subHeaderKey);
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",titleKey)));
         }
         if(m_window.hasOwnProperty("capacity_tf"))
         {
            addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Dialogs","OrchardDialog_Capacity",{
               "quantity":this.m_orchardBuilding.count,
               "quantityTotal":this.m_orchardBuilding.capacity
            })));
         }
         if(m_window.hasOwnProperty("goTo_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.goTo_mc,ZLocUtils.t("Dialogs","OrchardDialog_ShowTreeMastery"),this.onShowMasteryDialog));
         }
         if(m_window.hasOwnProperty("buy_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","OrchardDialog_BuyTrees"),this.onBuyTrees));
         }
         if(m_window.hasOwnProperty("ask_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t("Dialogs","OrchardDialog_AskTrees"),this.onAskForTrees));
         }
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onClickHowDoesThisWork));
         }
         if(this.m_orchardBuilding.isExpandable() && !Global.worldManager.isVisitingNeighbor() && m_window.hasOwnProperty("expandGroup_mc") && Boolean(m_window.expandGroup_mc.hasOwnProperty("expand_bt")))
         {
            expandGroup = new ZwFrame(m_window.expandGroup_mc);
            expandGroup.addWidget(new FarmAnimatedTextButton(expandGroup.element.expand_bt,ZLocUtils.t("Dialogs","Upgrade"),this.onExpandOrchard));
            addWidget(expandGroup);
         }
         if(m_window.hasOwnProperty("treeslots_mc"))
         {
            m_content_mc = addWidget(new OrchardFeatureBuildingSlotFrame(m_window.treeslots_mc,this.m_orchardBuilding,this)) as FarmSlotContainerFrame;
         }
         if(m_window.hasOwnProperty("inset_mc"))
         {
            addWidget(new ZwBaseWidget(m_window.inset_mc));
         }
         var expansionItems:Array = m_building.expand.getExpandSlotData();
         if(m_window.hasOwnProperty("expand_mc") && Boolean(expansionItems))
         {
            m_expand_mc = new GenericExpandSlotFrame(m_window.expand_mc,expansionItems,this,m_building,m_building.expand);
            addWidget(m_expand_mc,false);
            if(m_window.hasOwnProperty("strings_mc"))
            {
               addWidget(new ZwBaseWidget(m_window.strings_mc));
            }
            if(m_window.hasOwnProperty("featureTab_bt"))
            {
               if(m_contentTab_bt == null)
               {
                  m_contentTab_bt = new FarmAnimatedTextButton(m_window.featureTab_bt,ZLocUtils.t("Dialogs","Contents"),onShowContents);
               }
               addWidget(m_contentTab_bt);
            }
            if(m_window.hasOwnProperty("expandTab_mc"))
            {
               m_expandTab_bt = new FarmAnimatedTextButton(m_window.expandTab_mc,ZLocUtils.t("Dialogs","expand_farm_submenu"));
               addWidget(m_expandTab_bt);
            }
            m_toggleManager = new ZwToggleManager();
            if(StorageContentsWindow.m_state == StorageContentsWindow.VIEW_EXPAND && Boolean(m_expand_mc))
            {
               m_toggleManager.addToggle(new ZwVisibilityToggle(m_expandTab_bt,m_expand_mc),true);
               m_toggleManager.addToggle(new ZwVisibilityToggle(m_contentTab_bt,m_content_mc));
               if(m_building.storageLevel == 1)
               {
                  showFirstExpandDialog();
               }
            }
            else if(m_expand_mc)
            {
               m_toggleManager.addToggle(new ZwVisibilityToggle(m_expandTab_bt,m_expand_mc));
               m_toggleManager.addToggle(new ZwVisibilityToggle(m_contentTab_bt,m_content_mc),true);
            }
            else
            {
               m_content_mc.visible = true;
            }
            if(m_window.hasOwnProperty("subheader_tf"))
            {
               addWidget(new ZwTextField(m_window.subheader_tf,ZLocUtils.t("Dialogs",subHeaderKey)));
            }
         }
      }
      
      private function onShowMasteryDialog(event:Event) : void
      {
         this.close();
         UI.displayPopup(new MasteryWindow(MasteryWindow.TYPE_TREE));
      }
      
      private function onBuyTrees(event:Event) : void
      {
         var marketTrees:Array = null;
         var marketTreeNames:Array = null;
         var farmItem:FarmItem = null;
         marketTrees = Global.farmGameSettingsManager.getFarmItemsArray("seed","tree","",FarmGameSettingsManager.DEFAULT,FarmGameSettingsManager.ASCENDING);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SORT_ORCHARD_ITEMS) >= Experiments.VARIANT_SORT_ORCHARD_ITEMS)
         {
            marketTrees.sort(Global.farmGameSettingsManager.getItemSortFunction(FarmGameSettingsManager.CURRENT_WORLD_SORT));
            marketTrees.reverse();
         }
         marketTreeNames = [];
         for each(farmItem in marketTrees)
         {
            marketTreeNames.push(farmItem.name);
         }
         this.close();
         UI.displayMiniMarketDialog(marketTreeNames,"tree","tree",null,true,true);
      }
      
      private function onExpandOrchard(event:Event) : void
      {
         this.close();
      }
      
      private function onAskForTrees(event:Event) : void
      {
         this.close();
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","orchard_ask_trees");
         Global.farmSocialNetwork.farmRedirect(ASK_FOR_TREES_URL);
      }
      
      private function treeMiniMarketFilter(itemData:Array, index:int, array:Array) : Boolean
      {
         var result:Boolean = true;
         var itemName:String = "";
         if(Boolean(itemData) && Boolean(itemData.length > 0) && Boolean(itemData[0].name))
         {
            itemName = itemData[0].name;
         }
         if(m_excludeMiniMarketItems.indexOf(itemName) != -1)
         {
            result = false;
         }
         return result;
      }
      
      private function getTreeItemName(itemData:Array, index:int, array:Array) : String
      {
         var result:String = null;
         if(Boolean(itemData) && Boolean(itemData.length > 0) && Boolean(itemData[0].name))
         {
            result = itemData[0].name;
         }
         return result;
      }
      
      private function onClickHowDoesThisWork(event:MouseEvent) : void
      {
         TutorialUI.displayOrchardsTutorialWindow(this.m_orchardBuilding);
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_orchardBuilding = null;
         this.m_buildingName = null;
      }
   }
}

