package Events
{
   public class RegionAchievementEvent extends DynamicObjectEvent
   {
      
      public static const TABBED_WINDOW_CLICK_HANDLER:String = "tabbed_window_click_handler";
      
      public static const CHAMPION_ICON_CLK:String = "CHAMPION_ICON_CLK";
      
      public static const CHECKOUT_ST:String = "CHECKOUT_ST";
      
      public static const REFRESH_UI:String = "REFRESH_UI";
      
      public static const UPDATE_HUD:String = "UPDATE_HUD";
      
      public static const SPECIAL_REWARD:String = "SPECIAL_REWARD";
      
      public static const EXECUTE_NEXT_ACTION:String = "EXECUTE_NEXT_ACTION";
      
      public static const TOGGLE_MAIN_WINDOW_NPC:String = "TOGGLE_MAIN_WINDOW_NPC";
      
      public function RegionAchievementEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,data,bubbles,cancelable);
      }
   }
}

