package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class ExtraDataFManager extends FeatureManager implements IExtraDataComponent
   {
      
      private var ClassCompilingArray:Array = [AnimalBreedingState,DragonBreedingState];
      
      private var m_extraDataState:Object;
      
      public function ExtraDataFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function loadObject(data:Object) : void
      {
         if(Boolean(data) && Boolean(data.extraDataState))
         {
            this.m_extraDataState = data.extraDataState;
         }
      }
      
      public function getProperty(propertyName:String) : *
      {
         var result:* = null;
         if(Boolean(this.m_extraDataState) && this.m_extraDataState.hasOwnProperty(propertyName))
         {
            result = this.m_extraDataState[propertyName];
         }
         return result;
      }
   }
}

