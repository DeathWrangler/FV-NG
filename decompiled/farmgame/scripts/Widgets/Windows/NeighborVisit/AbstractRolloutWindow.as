package Widgets.Windows.NeighborVisit
{
   import Engine.Managers.LoadingManager;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import flash.display.Loader;
   
   public class AbstractRolloutWindow extends ZwAbstractWindow
   {
      
      public function AbstractRolloutWindow(url:String)
      {
         super(Global.getAssetURL(url));
      }
      
      public function tweenIn() : void
      {
         m_window.gotoAndPlay(1);
      }
      
      public function tweenOut() : void
      {
         m_window.gotoAndStop(1);
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback,LoadingManager.PRIORITY_HIGH);
      }
   }
}

