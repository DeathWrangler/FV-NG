package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class MoneyTreeConfirmationWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "generic_tf";
      
      protected var m_featureName:String;
      
      private var m_itemName:String = "";
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function MoneyTreeConfirmationWindow(featureName:String, assetPath:String, itemName:String)
      {
         this.m_featureName = featureName;
         this.m_itemName = itemName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_harvestTitle")));
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            addWidget(new ZwTextField(m_window[BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_harvestBody")));
         }
         if(m_window.hasOwnProperty("fv_cash_tf"))
         {
            addWidget(new ZwTextField(m_window["fv_cash_tf"],"2"));
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            this.m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Okay!",this.onAcceptCall)) as FarmAnimatedTextButton;
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      public function onAcceptCall(e:Event) : void
      {
         close();
      }
   }
}

