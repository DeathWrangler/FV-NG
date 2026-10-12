package Classes
{
   import flash.events.MouseEvent;
   
   public class InactiveFeatureBuilding extends FeatureBuilding
   {
      
      public function InactiveFeatureBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
      }
      
      override public function onMouseOut() : void
      {
      }
      
      override public function getCursor() : Class
      {
         return null;
      }
      
      override public function onClick() : void
      {
      }
      
      override public function isHarvestable() : Boolean
      {
         return true;
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         imageName = super.getCurrentImageName();
         m_arrowArt = null;
         m_hideArrow = true;
         return imageName;
      }
   }
}

