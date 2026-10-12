package Widgets.Windows.SheepPen
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class SheepPenWindow extends BreedingWindow
   {
      
      private static const TUTORIAL_SEEN_FLAG:String = "SheepPenTutorial";
      
      private static const SHEEP_PEN_FINISHED_BUILDING:String = "xuk_sheep_pen_finished";
      
      private static const MOTD_SEEN_FLAG_NEW_PATTERNS:String = "MOTD_PATTERN_SHEEP_BREEDING_2016";
      
      private static const NEW_PATTERNS_GRANTED_FLAG:String = "PatternSheepGranted";
      
      private static const DIALOG_SHEEP_PEN:String = "assets/dialogs/FV_SheepPen2_3.swf";
      
      private static const DIALOG_PATTERN_SHEEP_PEN:String = "assets/dialogs/FV_SheepPen2_4.swf";
      
      private static const sheepPenFeatureBuildingName:String = "sheep_pen";
      
      public static const SERVICE_CLASS:String = "SheepPenService";
      
      private var m_grantCardBuyButton:FarmAnimatedTextButton;
      
      private var m_grantCardTextField:ZwTextField;
      
      private var m_grantCardTextField2:ZwTextField;
      
      private var m_grantCard:ZwWidget;
      
      public function SheepPenWindow(building:FeatureBuilding)
      {
         super(building,DIALOG_PATTERN_SHEEP_PEN,sheepPenFeatureBuildingName);
      }
      
      public static function openUI(itemName:String) : void
      {
         var sheepPenFinishedBuilding:Array = Global.world.getObjectsByName(itemName);
         if(Boolean(sheepPenFinishedBuilding) && sheepPenFinishedBuilding.length > 0)
         {
            UI.displayPopup(new SheepPenWindow(sheepPenFinishedBuilding[0]));
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var buyButtonText:String = null;
         super.postLoadComplete();
         if(m_window.frame_inventory_mc.grantCard_mc)
         {
            addWidget(this.m_grantCard = new ZwWidget(m_window.frame_inventory_mc.grantCard_mc));
            this.m_grantCard.visible = true;
            this.attachTooltipToButton(this.m_grantCard,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Pattern_sheep_breeding_grant_tooltip"));
         }
         if(m_window.frame_inventory_mc.grantCard_mc.dynamicText2_tf)
         {
            addWidget(this.m_grantCardTextField = new ZwTextField(m_window.frame_inventory_mc.grantCard_mc.dynamicText2_tf,""));
         }
         if(m_window.frame_inventory_mc.grantCard_mc.dynamicText1_tf)
         {
            addWidget(this.m_grantCardTextField2 = new ZwTextField(m_window.frame_inventory_mc.grantCard_mc.dynamicText1_tf,""));
            this.m_grantCardTextField2.visible = false;
         }
         if(m_window.frame_inventory_mc.grantCard_mc.buyMore_bt)
         {
            buyButtonText = "Buy Now!";
            addWidget(this.m_grantCardBuyButton = new FarmAnimatedTextButton(m_window.frame_inventory_mc.grantCard_mc.buyMore_bt,buyButtonText,this.onBuyButtonClicked)) as FarmAnimatedTextButton;
            this.m_grantCardBuyButton.visible = false;
         }
         this.refreshWindow();
         if(!Global.player.getSeenFlag(NEW_PATTERNS_GRANTED_FLAG))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SheepPenWindow.SERVICE_CLASS,"grantFreePatterns",this.onPatternsGranted,[m_featureName,"allNewSheepPattern2016"]),true);
         }
         if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG))
         {
            Global.player.setSeenFlag(TUTORIAL_SEEN_FLAG);
            TutorialUI.displaySheepPenTutorialWindow(false,null);
         }
         var numPotionsInventory:Number = AnimalBreedingManager.getInstance().getNumPotions();
         FarmStatsManager.count(sheepPenFeatureBuildingName,"MainUI","View",Global.player.level.toString(),numPotionsInventory.toString());
      }
      
      override public function refreshWindow() : void
      {
         if(this.m_grantCard)
         {
            if(!Global.player.getSeenFlag(NEW_PATTERNS_GRANTED_FLAG))
            {
               this.m_grantCardBuyButton.visible = false;
               this.m_grantCardTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Pattern_sheep_breeding_txt1");
            }
            else
            {
               this.m_grantCardBuyButton.visible = true;
               this.m_grantCardTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Pattern_sheep_breeding_txt2");
            }
         }
      }
      
      private function onBuyButtonClicked(e:Event) : void
      {
         this.showMarket();
      }
      
      private function onPatternsGranted(result:Object) : void
      {
         var itemName:String = null;
         var items:Array = result["gifts"];
         Global.player.setSeenFlag(NEW_PATTERNS_GRANTED_FLAG);
         for each(itemName in items)
         {
            Global.player.addGift(itemName,"0",1);
         }
         UI.refreshGiftBoxWindow();
         this.refreshWindow();
      }
      
      override protected function howDoesThisWorkCallback(event:MouseEvent) : void
      {
         TutorialUI.displaySheepPenTutorialWindow();
      }
      
      override protected function toggleUI(enable:Boolean = false) : void
      {
         if(this.m_grantCardBuyButton != null)
         {
            if(!enable)
            {
               this.m_grantCardBuyButton.enabled = false;
            }
            else
            {
               this.m_grantCardBuyButton.enabled = true;
            }
         }
         super.toggleUI(enable);
      }
      
      private function showMarket() : void
      {
         close();
         UI.displayMarketDialog("buyMoreSheepBreedingPatterns","animal",null,"breeding");
      }
      
      private function attachTooltipToButton(element:ZwWidget, message:String = "") : void
      {
         var infoTooltip:FarmTextTooltip = new FarmTextTooltip(message);
         element.attachTooltip(infoTooltip);
      }
   }
}

