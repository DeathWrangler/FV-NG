package Classes.FeatureComponents
{
   import Classes.MapResource;
   
   public interface IRenderComponent
   {
      
      function render() : void;
      
      function updateTransforms() : void;
      
      function updateDisplay() : void;
      
      function updateCulling() : void;
      
      function updateFeaturedObjects(param1:Number) : void;
      
      function setState(param1:String, param2:Object = null) : void;
      
      function addItem(param1:MapResource) : void;
      
      function removeContents(param1:String, param2:int = 1, param3:int = 0, param4:String = "") : void;
   }
}

