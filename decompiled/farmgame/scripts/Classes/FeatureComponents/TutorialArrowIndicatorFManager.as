package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Widgets.Windows.ArrowIndicatorWindow;
   
   public class TutorialArrowIndicatorFManager extends ArrowIndicatorFManager
   {
      
      public function TutorialArrowIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
         m_canShow = false;
      }
      
      override public function onMouseOver() : void
      {
      }
      
      override public function onMouseOut() : void
      {
      }
      
      override protected function createIndicator(state:String) : void
      {
         var arrowState:Object = m_states[state];
         if(arrowState != null)
         {
            m_indicator = new ArrowIndicatorWindow(arrowState.icon,arrowState.title,arrowState.desc,null,false,"assets/dialogs/Angler/bouncingArrow2.swf");
            setIndicatorPosition();
         }
      }
      
      public function set canShow(visibility:Boolean) : void
      {
         m_canShow = visibility;
      }
   }
}

