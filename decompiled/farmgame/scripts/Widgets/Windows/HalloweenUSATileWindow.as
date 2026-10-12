package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class HalloweenUSATileWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      public function HalloweenUSATileWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super("assets/dialogs/halloweenusa/innovation/FV_xha_Innovation_UnlockTiles.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         m_window.visible = true;
         if(Boolean(m_window) && Boolean(m_window.mainWindow))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_title")));
            }
            if(m_window.mainWindow.description_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.description_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_body")));
            }
            if(m_window.mainWindow.close_bt)
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onCloseButtonClick)) as FarmButton;
            }
            if(m_window.mainWindow.generic_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_bt,"Unlock Tiles",this.panToTile));
            }
         }
      }
      
      private function panToTile(e:Event) : void
      {
         HalloweenInnovationManager.getInstance().highlightTiles();
         close();
      }
      
      private function onCloseButtonClick(e:Event) : void
      {
         close();
      }
   }
}

