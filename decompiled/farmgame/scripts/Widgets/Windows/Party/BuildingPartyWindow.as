package Widgets.Windows.Party
{
   import Classes.ConstructionBuilding;
   import Classes.PartyBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.PartyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.ConstructionFrame;
   import Widgets.Frames.Party.*;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class BuildingPartyWindow extends FarmWindow
   {
      
      protected static const ASSET_URL:String = "assets/dialogs/FV_NYE_party.swf";
      
      protected var m_building:PartyBuilding;
      
      protected var m_constructionBuilding:ConstructionBuilding;
      
      public var m_guestListToggle:ZwVisibilityToggle;
      
      private var m_whatIsThisDialog:GenericXMLDialog;
      
      public var m_toggleManager:ZwToggleManager = null;
      
      public var partyCode:String;
      
      public function BuildingPartyWindow(building:PartyBuilding = null, construction:ConstructionBuilding = null, code:String = "FS01")
      {
         PartyManager.getInstance().partyWindowOpen = true;
         this.m_building = building;
         this.m_constructionBuilding = construction;
         this.partyCode = code;
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         var buildFrame:ZwFrame = null;
         this.m_toggleManager = new ZwToggleManager();
         addWidget(new ZwTextField(m_window.title_tf,this.titleText()));
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,this.whatIsThisButtonText(),this.onWhatIsThisButtonClick));
         var progressButton:FarmAnimatedTextButton = addWidget(new FarmAnimatedTextButton(m_window.navTab1_bt,this.progressTabText())) as FarmAnimatedTextButton;
         var guestListButton:FarmAnimatedTextButton = addWidget(new FarmAnimatedTextButton(m_window.navTab2_bt,this.guestListTabText())) as FarmAnimatedTextButton;
         var buildButton:FarmAnimatedTextButton = addWidget(new FarmAnimatedTextButton(m_window.navTab3_bt,this.buildTabText())) as FarmAnimatedTextButton;
         var partyIsFull:Boolean = this.isPartyFull() || !PartyManager.getInstance().getPartyObjectByCode(this.partyCode).goal.isEnabled();
         var enabledFeature:Boolean = PartyManager.getInstance().getPartyObjectByCode(this.partyCode).goal.isEnabled();
         var guestListFrame:PartyGuestListFrame = addWidget(new PartyGuestListFrame(m_window.guestFrame_mc,partyIsFull,enabledFeature),false) as PartyGuestListFrame;
         this.m_guestListToggle = new ZwVisibilityToggle(guestListButton,guestListFrame);
         this.m_toggleManager.addToggle(this.m_guestListToggle);
         var progressFrame:PartyProgressFrame = addWidget(new PartyProgressFrame(m_window.progressFrame_mc,this),false) as PartyProgressFrame;
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(progressButton,progressFrame),this.m_constructionBuilding == null);
         var isConstruction:Boolean = false;
         if(this.m_constructionBuilding)
         {
            buildFrame = addWidget(new ConstructionFrame(m_window.expandFrame_mc,this.m_constructionBuilding,this),false) as ZwFrame;
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(buildButton,buildFrame),true);
            isConstruction = true;
         }
         else
         {
            buildButton.applyGrayOut = true;
            buildButton.visible = false;
         }
      }
      
      protected function isPartyFull() : Boolean
      {
         var currentCount:Number = PartyManager.getInstance().getPartyObjectByCode(this.partyCode).friendSet.numFriendsCompleted;
         var maxCount:Number = PartyManager.getInstance().getPartyObjectByCode(this.partyCode).goal.getMaximumLevelRequirement();
         return currentCount >= maxCount;
      }
      
      private function titleText() : String
      {
         return ZLocUtils.t("Dialogs","PartyWindow_Title");
      }
      
      private function whatIsThisButtonText() : String
      {
         return ZLocUtils.t("Dialogs","PartyWindow_WhatIsThisButton");
      }
      
      private function whatIsThisDialogText() : String
      {
         return ZLocUtils.t("Dialogs","PartyWindow_WhatIsThisDialog");
      }
      
      private function progressTabText() : String
      {
         return ZLocUtils.t("Dialogs","PartyWindow_ProgressTab");
      }
      
      private function guestListTabText() : String
      {
         return ZLocUtils.t("Dialogs","PartyWindow_GuestListTab");
      }
      
      private function buildTabText() : String
      {
         var result:String = ZLocUtils.t("Dialogs","PartyWindow_BuildTab");
         if(this.m_constructionBuilding == null)
         {
            result = ZLocUtils.t("Dialogs","PartyWindow_BuildCompleteTab");
         }
         return result;
      }
      
      private function onWhatIsThisButtonClick(evt:MouseEvent) : void
      {
         var imageSize:Number = 100;
         this.m_whatIsThisDialog = new GenericXMLDialog("","",null,null,imageSize,imageSize,this.whatIsThisDialogText(),this.onWhatIsThisClose,false,ZLocUtils.t("Dialogs","Accept"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_LARGE);
         UI.displayPopup(this.m_whatIsThisDialog,false,"PartyWindow_WhatIsThisPopup",true);
         enableInput = false;
      }
      
      private function onWhatIsThisClose(event:GenericPopupEvent) : void
      {
         enableInput = true;
         this.m_whatIsThisDialog = null;
      }
      
      override public function close() : void
      {
         PartyManager.getInstance().partyWindowOpen = false;
         super.close();
      }
   }
}

