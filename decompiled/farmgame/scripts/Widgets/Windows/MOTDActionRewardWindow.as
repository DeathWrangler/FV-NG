package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   
   public class MOTDActionRewardWindow extends FarmWindow
   {
      
      private var m_bundleKey:String;
      
      public function MOTDActionRewardWindow(asset:String, bundleKey:String)
      {
         this.m_bundleKey = bundleKey;
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwFrame(m_window.mainWindow));
            addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs",this.m_bundleKey + "_title")));
            addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs",this.m_bundleKey + "_body")));
            addWidget(new FarmTextField(m_window.mainWindow.market_tf,ZLocUtils.t("Dialogs",this.m_bundleKey + "_market")));
            addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs",this.m_bundleKey + "_acceptBt"),onClose));
         }
      }
   }
}

