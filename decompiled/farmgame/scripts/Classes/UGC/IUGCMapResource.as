package Classes.UGC
{
   import Classes.IMapResourceLayerContainer;
   
   public interface IUGCMapResource extends IMapResourceLayerContainer
   {
      
      function get ugcDelegate() : UGCResourceDelegate;
      
      function get ugcUuid() : String;
      
      function set ugcUuid(param1:String) : void;
      
      function get isCustomizable() : Boolean;
   }
}

