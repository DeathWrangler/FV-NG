package Widgets.Windows
{
   import Widgets.Icons.FarmIcon;
   
   public class FarmWindowWithBackground extends FarmWindow
   {
      
      protected var m_backgroundImage:String = null;
      
      protected var m_backgroundIcon:FarmIcon = null;
      
      public function FarmWindowWithBackground(windowAssetRelUrl:String, backgroundImage:String)
      {
         super(windowAssetRelUrl,true,false);
         this.m_backgroundImage = backgroundImage;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("background_mc") && this.m_backgroundImage is String && this.m_backgroundImage != "")
         {
            this.m_backgroundIcon = new FarmIcon(m_window["background_mc"],this.m_backgroundImage);
            addWidget(this.m_backgroundIcon,true);
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         if(this.m_backgroundIcon is FarmIcon && this.m_backgroundImage is String && this.m_backgroundImage != "")
         {
            this.m_backgroundIcon.loadIcon(this.m_backgroundImage);
         }
      }
   }
}

