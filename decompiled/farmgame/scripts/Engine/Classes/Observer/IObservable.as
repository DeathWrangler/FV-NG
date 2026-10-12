package Engine.Classes.Observer
{
   public interface IObservable
   {
      
      function addObserver(param1:IObserver, param2:Vector.<String> = null) : void;
      
      function removeObserver(param1:IObserver, param2:Vector.<String> = null) : void;
      
      function getObservableEvents() : Vector.<String>;
   }
}

