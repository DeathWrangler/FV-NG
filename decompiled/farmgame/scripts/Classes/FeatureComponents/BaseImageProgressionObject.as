package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class BaseImageProgressionObject implements IImageProgressionObject
   {
      
      protected var m_owner:FeatureBuilding;
      
      public function BaseImageProgressionObject(owner:FeatureBuilding)
      {
         super();
         this.m_owner = owner;
      }
      
      public function setProgression() : void
      {
      }
      
      public function onDetatch() : void
      {
      }
   }
}

