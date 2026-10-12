package Widgets.Windows
{
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class CongratsWindowLg extends FarmWindow
   {
      
      protected static const POPUP_NAME:String = "congratsPopup";
      
      protected var DIALOG_ASSET:String = "assets/dialogs/FV_GenericPopUp_Congrats_lrg.swf";
      
      protected var m_onShareCallback:Function = null;
      
      protected var m_title:String = "";
      
      protected var m_message:String = "";
      
      protected var m_leftIconAsset:String = "";
      
      protected var m_rightIconAsset:String = "";
      
      public function CongratsWindowLg(title:String, message:String, leftIconAsset:String, rightIconAsset:String, onShareCallback:Function)
      {
         super(this.DIALOG_ASSET);
         this.name = POPUP_NAME;
         this.m_title = title;
         this.m_message = message;
         this.m_leftIconAsset = leftIconAsset;
         this.m_rightIconAsset = rightIconAsset;
         this.m_onShareCallback = onShareCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemIconLeft:FarmIcon = null;
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.popupBox_mc));
         addWidget(new FarmAnimatedButton(m_window.popupBox_mc.accept_bt,this.m_onShareCallback));
         addWidget(new FarmAnimatedButton(m_window.popupBox_mc.cancel_bt,this.onClose));
         var textField:ZwTextField = new ZwTextField(m_window.popupBox_mc.popupBox_tf);
         textField.text = this.m_message;
         addWidget(textField);
         var titleField:ZwTextField = new ZwTextField(m_window.popupBox_mc.goldTitle_tf);
         titleField.text = this.m_title;
         addWidget(titleField);
         itemIconLeft = new FarmIcon(m_window.popupBox_mc.eventIconLeft_mc);
         itemIconLeft.loadIcon(this.m_leftIconAsset);
         itemIconLeft.visible = true;
         addWidget(itemIconLeft);
         var itemIconRight:FarmIcon = new FarmIcon(m_window.popupBox_mc.eventIconRight_mc);
         itemIconRight.loadIcon(this.m_rightIconAsset);
         itemIconRight.visible = true;
         addWidget(itemIconRight);
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         FarmStatsManager.count("dialog","lightningcollections-trade_in_collection","X");
      }
   }
}

