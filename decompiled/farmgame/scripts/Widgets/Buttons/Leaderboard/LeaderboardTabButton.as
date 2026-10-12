package Widgets.Buttons.Leaderboard
{
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Managers.ZwWidgetManager;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObjectContainer;
   
   public class LeaderboardTabButton extends FarmTabButton
   {
      
      private static const ICON_SIZE:int = 25;
      
      private var m_icon:FarmIcon;
      
      protected var m_iconWidigetManager:ZwWidgetManager = new ZwWidgetManager();
      
      public function LeaderboardTabButton(element:DisplayObjectContainer, text:String = "", iconUrl:String = "", callback:Function = null)
      {
         super(element,text,callback);
         this.m_iconWidigetManager = new ZwWidgetManager();
         this.m_icon = this.m_iconWidigetManager.addWidget(new FarmIcon(m_element.tabImage_tf)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_icon.loadIcon(iconUrl);
      }
      
      override public function release() : void
      {
         this.m_iconWidigetManager.release();
         this.m_iconWidigetManager = null;
         this.m_icon = null;
         super.release();
      }
      
      public function get iconUrl() : String
      {
         return this.m_icon.iconUrl;
      }
      
      public function set iconUrl(value:String) : void
      {
         this.m_icon.loadIcon(value);
      }
   }
}

