package Classes.FeatureComponents
{
   public interface IStateIndicatorComponent
   {
      
      function canDisplay() : Boolean;
      
      function onClick() : void;
      
      function show(param1:String = "") : void;
      
      function hide() : void;
      
      function onMouseOver() : void;
      
      function onMouseOut() : void;
   }
}

