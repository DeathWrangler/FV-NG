package Widgets.Frames.Clubs
{
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.Clubs.DataObjects.FarmClub;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FarmClubSettingsFrame extends ZwFrame
   {
      
      private static const CLUB_NAME_MAX_CHARS:int = 12;
      
      private var m_inputNameTf:FarmTextField;
      
      private var m_resignButton:FarmAnimatedTextButton;
      
      private var m_saveButton:FarmAnimatedTextButton;
      
      private var m_checkmark:ZwWidget;
      
      private var m_checkBox:ZwButton;
      
      private var m_closeButton:FarmButton;
      
      private var m_clubLogoSelector:ClubLogoSlotContainerFrame;
      
      private var m_saveCallback:Function = null;
      
      private var m_parentWindow:FarmClubWindow2 = null;
      
      public function FarmClubSettingsFrame(element:DisplayObject, farmClub:FarmClub, onSaveCallback:Function, parentWindow:FarmClubWindow2 = null)
      {
         super(element);
         this.m_saveCallback = onSaveCallback;
         this.m_parentWindow = parentWindow;
         if(m_element.close_bt)
         {
            this.m_closeButton = addWidget(new FarmButton(m_element.close_bt,this.onClose)) as FarmButton;
         }
         if(m_element.leave_bt)
         {
            this.m_resignButton = addWidget(new FarmAnimatedTextButton(m_element.leave_bt,ZLocUtils.t("FarmClub","clubLeave"),this.onLeaveClub)) as FarmAnimatedTextButton;
         }
         if(farmClub == null || farmClub.getLeader() == Global.player.uid)
         {
            addWidget(new ZwWidget(m_element.inputFieldBG_mc));
            addWidget(new ZwTextField(m_element.clubPublic_tf,ZLocUtils.t("FarmClub","CreateClub_Public")));
            addWidget(new ZwTextField(m_element.clubName_tf,ZLocUtils.t("FarmClub","CreateClub_ClubName")));
            addWidget(new ZwTextField(m_element.publicInstructions_tf,ZLocUtils.t("FarmClub","CreateClub_Public_Instructions")));
            addWidget(new ZwTextField(m_element.clubLogo_tf,ZLocUtils.t("FarmClub","CreateClub_ClubLogo")));
            this.m_inputNameTf = addWidget(new FarmTextField(m_element.inputName_tf,farmClub != null ? farmClub.clubName : "")) as FarmTextField;
            (this.m_inputNameTf.element as TextField).maxChars = CLUB_NAME_MAX_CHARS;
            this.m_saveButton = addWidget(new FarmAnimatedTextButton(m_element.save_bt,ZLocUtils.t("Dialogs","CustomizeRingEditRing"),this.onSave)) as FarmAnimatedTextButton;
            this.m_checkBox = addWidget(new FarmAnimatedButton(m_element.checkBox_mc,this.onCheckmarkClicked)) as ZwButton;
            this.m_checkmark = addWidget(new ZwWidget(m_element.checkMark_mc)) as ZwWidget;
            this.m_checkmark.visible = farmClub != null ? !farmClub.isPrivate : true;
            (this.m_checkmark.element as MovieClip).mouseEnabled = false;
            this.m_clubLogoSelector = addWidget(new ClubLogoSlotContainerFrame(m_element.logos_mc)) as ClubLogoSlotContainerFrame;
            this.m_clubLogoSelector.onLogoClicked(farmClub != null ? farmClub.clubLogoId.toString() : "1");
         }
         else
         {
            addWidget(new ZwTextField(m_element.notLeader_tf,ZLocUtils.t("FarmClub","notLeader")));
            addWidget(new ZwTextField(m_element.leave_tf,ZLocUtils.t("FarmClub","leaveConf")));
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_inputNameTf = null;
         this.m_saveButton = null;
         this.m_checkBox = null;
         this.m_checkmark = null;
         this.m_clubLogoSelector = null;
         this.m_resignButton = null;
         this.m_closeButton = null;
         this.m_parentWindow = null;
         this.m_saveCallback = null;
      }
      
      private function onClose(event:Event) : void
      {
         this.visible = false;
      }
      
      private function onSave(event:Event) : void
      {
         var clubNameInput:String = this.m_inputNameTf.text;
         var clubLogoId:String = this.m_clubLogoSelector.selectedLogoId;
         var isPrivate:Boolean = !this.m_checkmark.visible;
         this.m_saveCallback(clubNameInput,clubLogoId,isPrivate);
         this.onClose(event);
      }
      
      private function onLeaveClub(event:Event) : void
      {
         var message:GenericDialog = null;
         message = UI.showMessage(ZLocUtils.t("FarmClub","resignConfirm"),UI.BUTTON_LAYOUT_YES_NO,null,null,false,function(e:Event):void
         {
            FarmClubUtility.resign(onResignComplete);
            message.destroy();
            hideAllWidgets();
         });
      }
      
      private function onResignComplete(result:Object) : void
      {
         UI.displayPopup(new GenericPopup(ZLocUtils.t("FarmClub","LeaveClub_notification")),false);
         if(this.m_parentWindow)
         {
            this.m_parentWindow.close();
         }
      }
      
      private function onCheckmarkClicked(event:Event) : void
      {
         if(this.m_checkmark != null)
         {
            this.m_checkmark.visible = !this.m_checkmark.visible;
            (this.m_checkmark.element as MovieClip).mouseEnabled = false;
         }
      }
      
      public function repopulateClubData(farmClub:FarmClub) : void
      {
         this.m_inputNameTf.text = farmClub.clubName;
         this.m_checkmark.visible = !farmClub.isPrivate;
      }
   }
}

