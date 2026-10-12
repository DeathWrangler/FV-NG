package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.GenericPopup;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Clubs.FarmClubWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ClubSettingsFrame extends ZwFrame
   {
      
      private var m_inputNameTf:FarmTextField;
      
      private var m_resignButton:FarmAnimatedButton;
      
      private var m_saveButton:FarmAnimatedButton;
      
      private var m_checkmark:ZwWidget;
      
      private var m_checkBox:ZwButton;
      
      private var m_logo:ZwWidget;
      
      private var m_closeButton:FarmButton;
      
      private var m_clubDataCallbackId:int = 0;
      
      private var m_clubPublicTextfield:ZwTextField;
      
      private var m_publicMessageTextField:ZwTextField;
      
      private var m_clubNameTextfield:ZwTextField;
      
      private var m_createLogoTextField:ZwTextField;
      
      private var m_clubLogoSelector:ClubLogoSlotContainerFrame;
      
      private var m_loading:Boolean = false;
      
      public function ClubSettingsFrame(element:DisplayObject)
      {
         super(element);
         this.m_inputNameTf = addWidget(new FarmTextField(m_element.inputName_tf,"",false,true)) as FarmTextField;
         this.m_saveButton = addWidget(new FarmAnimatedButton(m_element.save_bt,this.onSaveButtonClicked)) as FarmAnimatedButton;
         this.m_checkBox = addWidget(new FarmAnimatedButton(m_element.checkBox_mc,this.onCheckmarkClicked)) as ZwButton;
         this.m_checkmark = addWidget(new ZwWidget(m_element.checkMark_mc)) as ZwWidget;
         (this.m_checkmark.element as MovieClip).mouseEnabled = false;
         this.m_clubLogoSelector = addWidget(new ClubLogoSlotContainerFrame(m_element.logos_mc)) as ClubLogoSlotContainerFrame;
         this.m_clubPublicTextfield = addWidget(new ZwTextField(m_element.clubPublic_tf,ZLocUtils.t("FarmClub","CreateClub_Public"))) as ZwTextField;
         this.m_clubNameTextfield = addWidget(new ZwTextField(m_element.clubName_tf,ZLocUtils.t("FarmClub","CreateClub_ClubName"))) as ZwTextField;
         this.m_publicMessageTextField = addWidget(new ZwTextField(m_element.publicInstructions_tf,ZLocUtils.t("FarmClub","CreateClub_Public_Instructions"))) as ZwTextField;
         this.m_createLogoTextField = addWidget(new ZwTextField(m_element.clubLogo_tf,ZLocUtils.t("FarmClub","CreateClub_ClubLogo"))) as ZwTextField;
         this.m_resignButton = addWidget(new FarmAnimatedButton(m_element.leave_bt,this.onResignButtonClicked)) as FarmAnimatedButton;
         this.m_closeButton = addWidget(new FarmButton(m_element.close_bt,this.onCloseButtonClicked)) as FarmButton;
         this.hideAllWidgets();
      }
      
      public function refresh() : void
      {
         var farmClubObj:FarmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
         if(farmClubObj == null)
         {
            this.unregisterClubDataCallback();
            this.m_clubDataCallbackId = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.FARM_CLUB_DATA,this.render);
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT));
            this.m_loading = true;
         }
         else
         {
            this.render(farmClubObj);
         }
         if(this.m_loading)
         {
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT));
         }
      }
      
      private function unregisterClubDataCallback() : void
      {
         if(this.m_clubDataCallbackId != FarmClubDataManager.UNREGISTERED)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_clubDataCallbackId);
            this.m_clubDataCallbackId = FarmClubDataManager.UNREGISTERED;
         }
      }
      
      private function render(farmClubDataObject:FarmClubDataObject) : void
      {
         if(farmClubDataObject.farmClub.getLeader() == String(Global.player.uid))
         {
            this.m_inputNameTf.visible = true;
            this.m_saveButton.visible = true;
            this.m_checkBox.visible = true;
            this.m_checkmark.visible = true;
            (this.m_checkmark.element as MovieClip).mouseEnabled = false;
            this.m_inputNameTf.text = farmClubDataObject.farmClub.clubName;
            this.m_clubPublicTextfield.visible = true;
            this.m_clubNameTextfield.visible = true;
            this.m_publicMessageTextField.visible = true;
            this.m_createLogoTextField.visible = true;
            this.m_clubLogoSelector.visible = true;
         }
         this.m_resignButton.visible = true;
         this.m_closeButton.visible = true;
      }
      
      override public function release() : void
      {
         super.release();
         this.unregisterClubDataCallback();
         this.m_inputNameTf = null;
         this.m_resignButton = null;
         this.m_saveButton = null;
         this.m_checkBox = null;
         this.m_checkmark = null;
         this.m_logo = null;
         this.m_clubPublicTextfield = null;
         this.m_publicMessageTextField = null;
         this.m_clubNameTextfield = null;
         this.m_createLogoTextField = null;
      }
      
      public function onCloseButtonClicked(event:Event) : void
      {
         this.visible = false;
      }
      
      public function onResignButtonClicked(event:Event) : void
      {
         var message:GenericDialog = null;
         message = UI.showMessage(ZLocUtils.t("FarmClub","resignConfirm"),UI.BUTTON_LAYOUT_YES_NO,null,null,false,function(e:Event):void
         {
            FarmClubUtility.resign(onResignComplete);
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT,FarmClubWindow.MY_CLUB_FRAME));
            m_loading = true;
            message.destroy();
         });
      }
      
      public function onSaveButtonClicked(event:Event) : void
      {
         var clubNameInput:String = this.m_inputNameTf.text;
         var clubLogoId:String = this.m_clubLogoSelector.selectedLogoId;
         var isPrivate:Boolean = !this.m_checkmark.visible;
         FarmClubUtility.updateClubInfo(clubNameInput,clubLogoId,isPrivate);
         var farmClubObj:FarmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
         if(farmClubObj != null)
         {
            farmClubObj.farmClub.clubName = clubNameInput;
            farmClubObj.farmClub.clubLogoId = parseInt(clubLogoId);
            farmClubObj.farmClub.isPrivate = isPrivate;
            farmClubObj.setDirty();
         }
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.ON_REFRESH_MYFRAME));
         this.visible = false;
      }
      
      public function onCheckmarkClicked(event:Event) : void
      {
         if(this.m_checkmark != null)
         {
            this.m_checkmark.visible = !this.m_checkmark.visible;
            (this.m_checkmark.element as MovieClip).mouseEnabled = false;
         }
      }
      
      public function onResignComplete(result:Object) : void
      {
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_COMPLETE_EVENT,FarmClubWindow.MY_CLUB_FRAME));
         this.m_loading = false;
         UI.displayPopup(new GenericPopup(ZLocUtils.t("FarmClub","LeaveClub_notification")),false);
      }
   }
}

