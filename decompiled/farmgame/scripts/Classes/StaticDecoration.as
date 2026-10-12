package Classes
{
   public class StaticDecoration extends Decoration
   {
      
      public function StaticDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function setHighlighted(highlighted:Boolean, color:uint = 16755200) : void
      {
         super.setHighlighted(false);
      }
   }
}

