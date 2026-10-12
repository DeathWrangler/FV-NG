package Classes
{
   import Classes.util.ZLocUtils;
   import Engine.Constants;
   
   public class DoghouseAnimal extends MutableAnimal
   {
      
      public static const STATE_FRONT_LYINGDOWN:String = "frt_lyingdown";
      
      public static const STATE_FRONT_SCRATCHING:String = "frt_scratching";
      
      public static const STATE_FRONT_SITTING:String = "frt_sitting";
      
      public static const STATE_BACK_LYINGDOWN:String = "bk_lyingdown";
      
      public static const STATE_BACK_SCRATCHING:String = "bk_scratching";
      
      public static const STATE_BACK_SITTING:String = "bk_sitting";
      
      public function DoghouseAnimal(animalType:String = null, metadata:String = null)
      {
         super(animalType,metadata);
         useBaseAnimalState();
      }
      
      override protected function setAnimalState() : void
      {
      }
      
      override public function setRandomAnimalState() : void
      {
      }
      
      override protected function generateMenuItems() : void
      {
         super.generateMenuItems();
         m_menuItems.push({
            "label":ZLocUtils.t("FarmGame","Rename"),
            "action":CHANGE_NAME
         });
      }
      
      override public function getCurrentImageName() : String
      {
         var imageNames:Array = null;
         if(m_direction == Constants.DIRECTION_SE || m_direction == Constants.DIRECTION_SW)
         {
            imageNames = new Array(STATE_FRONT_LYINGDOWN,STATE_FRONT_SCRATCHING,STATE_FRONT_SITTING);
         }
         else
         {
            imageNames = new Array(STATE_BACK_LYINGDOWN,STATE_BACK_SCRATCHING,STATE_BACK_SITTING);
         }
         var imageIndex:Number = Math.floor(Math.random() * imageNames.length);
         imageIndex = Math.min(imageIndex,imageNames.length - 1);
         return imageNames[imageIndex];
      }
      
      override protected function restartAnimation() : void
      {
         m_image = null;
         drawDisplayObject();
         super.restartAnimation();
      }
   }
}

