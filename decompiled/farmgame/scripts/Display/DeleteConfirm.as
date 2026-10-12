package Display
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.util.ZLocUtils;
   import GameMode.GMClear;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class DeleteConfirm extends Dialog
   {
      
      private var m_checkbox1:MovieClip = null;
      
      private var m_checkbox2:MovieClip = null;
      
      private var m_popupBoxText:TextField = null;
      
      private var m_option1Text:TextField = null;
      
      private var m_option2Text:TextField = null;
      
      private var m_accept:GenericButton = null;
      
      private var m_cancel:GenericButton = null;
      
      private var m_what:GenericButton = null;
      
      private var m_gameMode:GMClear;
      
      private var m_check1State:Boolean = false;
      
      private var m_check2State:Boolean = false;
      
      private var m_objectType:String;
      
      private var m_categoryType:String;
      
      public function DeleteConfirm(objectType:String, categoryType:String, modal:Boolean = true)
      {
         m_dialogAsset = "assets/dialogs/FV_delete_confirm.swf";
         this.m_objectType = objectType;
         this.m_categoryType = categoryType;
         super(modal);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.m_checkbox1 = m_window.popupBox_mc.checkbox1_mc as MovieClip;
         this.m_checkbox2 = m_window.popupBox_mc.checkbox2_mc as MovieClip;
         this.m_accept = new GenericButton(m_window.popupBox_mc.accept_bt,this.onAcceptClick);
         this.m_accept.text = ZLocUtils.t("Dialogs","Accept");
         this.m_cancel = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancelClick);
         this.m_cancel.text = ZLocUtils.t("Dialogs","Cancel");
         this.m_what = new GenericButton(m_window.popupBox_mc.whatisthis_mc,this.onWhatClick);
         this.m_what.text = ZLocUtils.t("Dialogs","WhatIsThis");
         this.m_popupBoxText = m_window.popupBox_mc.popupBox_tf as TextField;
         this.m_option1Text = m_window.popupBox_mc.option1_tf as TextField;
         this.m_option2Text = m_window.popupBox_mc.option2_tf as TextField;
         this.addText();
         this.setCheckMarks();
      }
      
      public function setReference(gameMode:GMClear) : void
      {
         this.m_gameMode = gameMode;
      }
      
      private function onAcceptClick(event:MouseEvent) : void
      {
         this.m_gameMode.sellOrDeleteObject();
         close();
      }
      
      private function onCancelClick(event:MouseEvent) : void
      {
         close();
      }
      
      private function onWhatClick(event:MouseEvent) : void
      {
         var genPop:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","QuickDeleteWhatIs"));
         Global.stage.addChild(genPop);
         genPop.show();
      }
      
      private function addText() : void
      {
         if(this.m_popupBoxText != null)
         {
            this.m_popupBoxText.htmlText = ZLocUtils.t("Dialogs","DeleteConfirmYouSure",{"item":ZLocUtils.tk_pk(this.m_objectType)});
         }
         if(this.m_option1Text != null)
         {
            this.m_option1Text.htmlText = ZLocUtils.t("Dialogs","DeleteConfirmPerSession",{"items":ZLocUtils.tk_pk(this.m_categoryType)});
         }
         if(this.m_option2Text != null)
         {
            this.m_option2Text.htmlText = ZLocUtils.t("Dialogs","DeleteConfirmQuickDelete");
         }
      }
      
      private function setCheckMarks() : void
      {
         this.m_checkbox1.gotoAndStop(1);
         this.m_checkbox2.gotoAndStop(1);
         this.m_checkbox1.buttonMode = true;
         this.m_checkbox2.buttonMode = true;
         this.m_checkbox1.addEventListener(MouseEvent.CLICK,this.onCheck1Click);
         this.m_checkbox2.addEventListener(MouseEvent.CLICK,this.onCheck2Click);
      }
      
      private function onCheck1Click(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         if(this.m_checkbox1.currentFrame == 1)
         {
            this.m_checkbox1.gotoAndStop(2);
            this.m_check1State = true;
            Global.persistentSell = true;
            this.m_checkbox2.gotoAndStop(1);
            this.m_check2State = false;
            FarmStatsManager.count("deletetool","suspend_session",this.m_categoryType);
         }
         else
         {
            this.m_checkbox1.gotoAndStop(1);
            this.m_check1State = false;
            Global.persistentSell = false;
         }
         Global.setQuickDelete(this.m_check2State);
      }
      
      private function onCheck2Click(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         if(this.m_checkbox2.currentFrame == 1)
         {
            this.m_checkbox2.gotoAndStop(2);
            this.m_check2State = true;
            this.m_checkbox1.gotoAndStop(1);
            this.m_check1State = false;
            Global.persistentSell = false;
            FarmStatsManager.count("deletetool","suspend_quickdelete");
         }
         else
         {
            this.m_checkbox2.gotoAndStop(1);
            this.m_check2State = false;
         }
         Global.setQuickDelete(this.m_check2State);
      }
      
      public function setCatAndObjType(catType:String, objType:String) : void
      {
         this.m_categoryType = catType;
         this.m_objectType = objType;
         this.addText();
      }
      
      public function getPersistentDeletingFlag() : Boolean
      {
         return this.m_check1State;
      }
      
      public function defaultCheck1ToEmpty() : void
      {
         if(this.m_checkbox1)
         {
            this.m_checkbox1.gotoAndStop(1);
            this.m_check1State = false;
         }
      }
   }
}

