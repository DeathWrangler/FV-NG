package Managers
{
   import Widgets.Windows.ToasterWindow;
   
   public class HudWidgetManager
   {
      
      private static var m_instance:HudWidgetManager = null;
      
      public function HudWidgetManager(objEnforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function get instance() : HudWidgetManager
      {
         if(m_instance == null)
         {
            m_instance = new HudWidgetManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public function add(hudWidget:ToasterWindow) : void
      {
         Global.ui.displayHudWidget(hudWidget);
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
