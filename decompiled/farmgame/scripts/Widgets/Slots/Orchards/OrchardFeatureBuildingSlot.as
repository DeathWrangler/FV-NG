package Widgets.Slots.Orchards
{
   import Classes.Mastery;
   import Classes.OrchardFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import GameMode.GMPlantTree;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Tooltips.MovieClipTooltip;
   import Widgets.Windows.Orchards.OrchardFeatureBuildingManagementWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OrchardFeatureBuildingSlot extends ZwSlotFrame
   {
      
      private static const QUANTITY_PREFIX:String = "x";
      
      private static const TOOLTIP_SHOW_FRAME_NUM:int = 30;
      
      private static const SUB_CARD_ICON_TRANSLATE_X:int = 17;
      
      private static const LEVEL_1_INDICATOR_FRAME:int = 1;
      
      private static const LEVEL_2_INDICATOR_FRAME:int = 2;
      
      private var m_removeButton:FarmAnimatedTextButton;
      
      private var m_treeIcon:FarmIcon;
      
      private var m_treeName:ZwTextField;
      
      private var m_treeQuantity:ZwTextField;
      
      private var m_data:Object;
      
      private var m_treeItem:FarmItem;
      
      private var m_treeItemName:String;
      
      private var m_nextLevelTreeItem:FarmItem;
      
      private var m_orchard:OrchardFeatureBuilding;
      
      private var m_parentWindow:OrchardFeatureBuildingManagementWindow;
      
      private var m_masteryProgressBar:FarmProgressBar;
      
      private var m_masteryStars:ZwFrame;
      
      private var m_nextTreeName:ZwTextField;
      
      private var m_nextTreeIcon:FarmIcon;
      
      private var m_buyUpgradeButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_masteryTooltip:FarmTextTooltip;
      
      private var m_topCardLevelIndicator:MovieClip;
      
      private var m_subCardLevelIndicator:MovieClip;
      
      public function OrchardFeatureBuildingSlot(element:DisplayObject, orchardBuilding:OrchardFeatureBuilding, parentWindow:OrchardFeatureBuildingManagementWindow)
      {
         var topCard:Object = null;
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_orchard = orchardBuilding;
         if(m_element.hasOwnProperty("topCard_mc"))
         {
            topCard = m_element.topCard_mc;
            if(topCard.hasOwnProperty("remove_bt"))
            {
               this.m_removeButton = addWidget(new FarmAnimatedTextButton(topCard.remove_bt,ZLocUtils.t("Dialogs","Remove"),this.onRemove)) as FarmAnimatedTextButton;
            }
            if(topCard.hasOwnProperty("icon_mc"))
            {
               this.m_treeIcon = addWidget(new FarmIcon(topCard.icon_mc)) as FarmIcon;
            }
            if(topCard.hasOwnProperty("treeName_tf"))
            {
               this.m_treeName = addWidget(new ZwTextField(topCard.treeName_tf)) as ZwTextField;
            }
            if(topCard.hasOwnProperty("quantity_tf"))
            {
               this.m_treeQuantity = addWidget(new ZwTextField(topCard.quantity_tf)) as ZwTextField;
            }
            if(topCard.hasOwnProperty("masteryInfo"))
            {
               this.m_masteryProgressBar = addWidget(new FarmProgressBar(topCard.masteryInfo)) as FarmProgressBar;
               this.m_masteryTooltip = new FarmTextTooltip();
               this.m_masteryProgressBar.attachTooltip(this.m_masteryTooltip);
               if(topCard.hasOwnProperty("stars_mc"))
               {
                  this.m_masteryStars = addWidget(new ZwFrame(topCard.stars_mc)) as ZwFrame;
               }
               if(topCard.hasOwnProperty("barContent_mc"))
               {
                  topCard.masteryInfo.barContent_mc.visible = true;
               }
            }
            if(topCard.hasOwnProperty("topStroke_mc"))
            {
               this.m_topCardLevelIndicator = topCard.topStroke_mc;
            }
            if(topCard.hasOwnProperty("buy_bt"))
            {
               this.m_buyButton = addWidget(new FarmAnimatedTextButton(topCard.buy_bt,ZLocUtils.t("Dialogs","BuyNow"),this.onBuyCurrentTree)) as FarmAnimatedTextButton;
            }
         }
         var subCard:Object = m_element.subCard_mc;
         if(subCard)
         {
            addWidget(new ZwTextField(subCard.makesSeeds_tf,ZLocUtils.t("Dialogs","OrchardDialog_MakesSeedsFor"))) as ZwTextField;
            this.m_nextTreeName = addWidget(new ZwTextField(subCard.nextTreeName_tf)) as ZwTextField;
            this.m_nextTreeIcon = addWidget(new FarmIcon(subCard.nextTreeIcon_mc)) as FarmIcon;
            this.m_nextTreeIcon.x += SUB_CARD_ICON_TRANSLATE_X;
            this.m_buyUpgradeButton = addWidget(new FarmAnimatedTextButton(subCard.buyNow_bt,ZLocUtils.t("Dialogs","BuyNow"),this.onBuyUpgradedTree)) as FarmAnimatedTextButton;
            this.attachTooltip(new MovieClipTooltip(element as MovieClip,TOOLTIP_SHOW_FRAME_NUM));
            if(subCard.subStroke_mc)
            {
               this.m_subCardLevelIndicator = subCard.subStroke_mc;
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refresh(data);
      }
      
      public function refresh(data:Object) : void
      {
         var mastery:Mastery = null;
         this.m_data = data;
         if(Boolean(this.m_data) && Boolean(this.m_data.item is FarmItem) && this.m_data.num > 0)
         {
            this.m_treeItem = this.m_data.item as FarmItem;
            if(this.m_data.name != null)
            {
               this.m_treeItemName = this.m_data.name;
            }
            else
            {
               this.m_treeItemName = this.m_treeItem.name;
            }
            this.m_treeIcon.loadIcon(this.m_treeItem.icon);
            this.m_treeName.text = this.m_treeItem.friendlyTitle;
            this.m_treeQuantity.text = QUANTITY_PREFIX + String(this.m_data.num);
            this.setLevelIndicator(this.m_topCardLevelIndicator,this.m_treeItem);
            this.m_nextLevelTreeItem = this.m_treeItem.getNextLevelItem();
            this.m_nextTreeName.text = this.m_nextLevelTreeItem.friendlyTitle;
            this.m_nextTreeIcon.loadIcon(this.m_nextLevelTreeItem.icon);
            this.m_buyUpgradeButton.visible = this.m_nextLevelTreeItem.buyable;
            this.m_buyButton.visible = this.m_treeItem.buyable;
            this.setLevelIndicator(this.m_subCardLevelIndicator,this.m_nextLevelTreeItem);
            mastery = Mastery.createMasteryForItem(this.m_treeItem);
            if(mastery.hasAllMasteries())
            {
               this.m_masteryProgressBar.progress = 100;
               this.m_masteryTooltip.setText(ZLocUtils.t("Dialogs","Mastered"));
            }
            else
            {
               this.m_masteryProgressBar.progress = mastery.currentProgress / mastery.totalCropsNeeded * 100;
               this.m_masteryTooltip.setText(ZLocUtils.t("Dialogs","MasteryProgress",{
                  "quantity":mastery.currentProgress,
                  "quantityTotal":mastery.totalCropsNeeded
               }));
            }
            (this.m_masteryStars.element as MovieClip).gotoAndStop(mastery.currentLevel + 2);
            this.m_treeIcon.visible = true;
            this.m_treeName.visible = true;
            this.m_treeQuantity.visible = true;
            this.m_removeButton.visible = true;
            this.m_masteryProgressBar.visible = true;
            this.m_masteryStars.visible = true;
            this.m_nextTreeName.visible = true;
            this.m_nextTreeIcon.visible = true;
            m_element.subCard_mc.makesSeeds_tf.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_removeButton = null;
         this.m_treeIcon = null;
         this.m_treeName = null;
         this.m_treeQuantity = null;
         this.m_data = null;
         this.m_treeItem = null;
         this.m_treeItemName = null;
         this.m_orchard = null;
         this.m_parentWindow = null;
         this.m_masteryProgressBar = null;
         this.m_masteryStars = null;
         this.m_nextTreeName = null;
         this.m_nextTreeIcon = null;
         this.m_buyUpgradeButton = null;
         this.m_masteryTooltip = null;
         super.release();
      }
      
      private function onRemove(event:Event) : void
      {
         if(!this.m_treeItemName)
         {
            this.m_treeItemName = this.m_treeItem.name;
         }
         Global.world.addGameMode(new GMPlantTree(this.m_treeItemName,false,this.m_orchard.getId()));
         this.m_parentWindow.close();
      }
      
      private function onBuyUpgradedTree(event:Event) : void
      {
         UI.displayMiniMarketDialog([this.m_nextLevelTreeItem.name],"tree","tree");
         this.m_parentWindow.close();
      }
      
      private function onBuyCurrentTree(event:Event) : void
      {
         UI.displayMiniMarketDialog([this.m_treeItem.name],"tree","tree");
         this.m_parentWindow.close();
      }
      
      private function setLevelIndicator(levelIndicator:MovieClip, tree:FarmItem) : void
      {
         var nextLevelTree:FarmItem = null;
         if(levelIndicator)
         {
            nextLevelTree = tree.getNextLevelItem();
            if(tree == nextLevelTree)
            {
               levelIndicator.gotoAndStop(LEVEL_2_INDICATOR_FRAME);
            }
            else
            {
               levelIndicator.gotoAndStop(LEVEL_1_INDICATOR_FRAME);
            }
         }
      }
   }
}

