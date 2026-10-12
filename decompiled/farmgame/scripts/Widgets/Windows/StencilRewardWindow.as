package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.StencilDecoration;
   import Managers.StencilManager;
   import Widgets.Buttons.FarmAnimatedTextButtonWithCallbackData;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   
   public class StencilRewardWindow extends FarmWindow
   {
      
      private var m_purchasedStencil:StencilDecoration;
      
      private var m_shareBtn:FarmAnimatedTextButtonWithCallbackData;
      
      public function StencilRewardWindow(assetPath:String, purchasedStencil:StencilDecoration)
      {
         super(assetPath);
         this.m_purchasedStencil = purchasedStencil;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmTextField(m_window.title_tf,this.manager.getString("reward_title")));
         addWidget(new FarmTextField(m_window.item_tf,this.manager.getString("reward_subtitle",ZLocConstants.DIALOG_UTIL_PKG,{"itemName":this.m_purchasedStencil.getItem().friendlyTitle})));
         addWidget(new FarmTextField(m_window.body_tf,this.manager.getString("reward_body",ZLocConstants.DIALOG_UTIL_PKG,{"itemName":this.m_purchasedStencil.getItem().friendlyTitle})));
         addWidget(new FarmIcon(m_window.icon_mc,this.m_purchasedStencil.getItem().getImageByName("feed")));
         addWidget(this.m_shareBtn = new FarmAnimatedTextButtonWithCallbackData(m_window.accept_bt,this.manager.getString("reward_share"),this.manager.brag));
         this.m_shareBtn.callbackData = this.m_purchasedStencil;
         this.refreshBragButton();
      }
      
      public function refreshBragButton() : void
      {
         var _bragTimeRemaining:int = this.manager.bragTimeRemaining;
         this.m_shareBtn.text = _bragTimeRemaining > 0 ? "Awesome!" : "Share!";
      }
      
      private function get manager() : StencilManager
      {
         return StencilManager.instance();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_purchasedStencil = null;
         this.m_shareBtn = null;
         this.manager.rewardWindow = null;
      }
   }
}

