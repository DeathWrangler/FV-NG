package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.MystreeNurseryManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class MystreeNurserySunshineCraftWindow extends FarmWindow
   {
      
      private var m_sunshineCraft:FarmAnimatedTextButton;
      
      private var m_sunshineBuy:FarmAnimatedTextButton;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      public function MystreeNurserySunshineCraftWindow()
      {
         super(MystreeNurseryManager.OUT_OF_SB_ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("craftbucket_bt"))
         {
            addWidget(this.m_sunshineCraft = new FarmAnimatedTextButton(m_window.craftbucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineCraftButtonText"),this.onSunshineCraftClick),true);
         }
         if(m_window.hasOwnProperty("buybucket_bt"))
         {
            addWidget(this.m_sunshineBuy = new FarmAnimatedTextButton(m_window.buybucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonText"),this.onSunshineBuyClick),true);
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeNurserySunshineCraftWindow_title")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeNurserySunshineCraftWindow_body")),true);
         }
      }
      
      private function onSunshineCraftClick(event:MouseEvent) : void
      {
         MystreeNurseryManager.getInstance().showCraftingWindowWithItem();
         close();
      }
      
      private function onSunshineBuyClick(event:MouseEvent) : void
      {
         var m_sunshineBuyWindow:MystreeNurserySunshineBuyWindow = new MystreeNurserySunshineBuyWindow();
         UI.displayPopup(m_sunshineBuyWindow,true,"",true);
         close();
      }
      
      override protected function release() : void
      {
         this.m_sunshineCraft = null;
         this.m_sunshineBuy = null;
         this.m_titleTf = null;
         this.m_bodyTf = null;
         super.release();
      }
   }
}

