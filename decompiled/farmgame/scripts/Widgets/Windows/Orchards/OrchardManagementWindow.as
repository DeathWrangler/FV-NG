package Widgets.Windows.Orchards
{
   import Classes.OrchardBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Orchards.OrchardsSlotFrame;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class OrchardManagementWindow extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_OrchardsManage.swf";
      
      private static const ASK_FOR_TREES_URL:String = "gifts.php?template=wishlist&ref=orchard";
      
      private static const m_excludeMiniMarketItems:Array = ["pkg_arborists","wateringcan"];
      
      private var m_orchardBuilding:OrchardBuilding;
      
      private var m_buildingName:String;
      
      public function OrchardManagementWindow(orchardBuilding:OrchardBuilding, buildingName:String = null)
      {
         super(DIALOG_ASSET);
         this.m_orchardBuilding = orchardBuilding;
         this.m_buildingName = buildingName;
      }
      
      override protected function postLoadComplete() : void
      {
         var expandGroup:ZwFrame = null;
         var key:String = "OrchardDialog_Title";
         if(Boolean(this.m_buildingName) && this.m_buildingName != "")
         {
            key = ZLocUtils.getExistingLocalizationKey("Dialogs",this.m_buildingName + "Dialog_Title",key);
         }
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",key)));
         addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Dialogs","OrchardDialog_Capacity",{
            "quantity":this.m_orchardBuilding.count,
            "quantityTotal":this.m_orchardBuilding.capacity
         })));
         addWidget(new FarmAnimatedTextButton(m_window.goTo_mc,ZLocUtils.t("Dialogs","OrchardDialog_ShowTreeMastery"),this.onShowMasteryDialog));
         addWidget(new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","OrchardDialog_BuyTrees"),this.onBuyTrees));
         addWidget(new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t("Dialogs","OrchardDialog_AskTrees"),this.onAskForTrees));
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onClickHowDoesThisWork));
         if(Boolean(!Global.worldManager.isVisitingNeighbor()) && Boolean(m_window.expandGroup_mc) && Boolean(m_window.expandGroup_mc.expand_bt) && this.m_orchardBuilding.isExpandable() == true)
         {
            expandGroup = new ZwFrame(m_window.expandGroup_mc);
            expandGroup.addWidget(new FarmAnimatedTextButton(expandGroup.element.expand_bt,ZLocUtils.t("Dialogs","Upgrade"),this.onExpandOrchard));
            addWidget(expandGroup);
         }
         addWidget(new OrchardsSlotFrame(m_window.treeslots_mc,this.m_orchardBuilding,this));
         if(m_window.inset_mc != null)
         {
            m_window.inset_mc.visible = true;
         }
         m_window.bgGradient_mc.visible = true;
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
         UI.displayPopup(new SuperOrchardsOnboardingWindow(this.m_orchardBuilding));
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

