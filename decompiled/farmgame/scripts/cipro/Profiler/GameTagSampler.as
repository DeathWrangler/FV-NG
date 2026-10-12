package cipro.Profiler
{
   public interface GameTagSampler
   {
      
      function sample() : void;
      
      function name() : String;
      
      function average() : Number;
      
      function min() : Number;
      
      function max() : Number;
      
      function value() : *;
      
      function reset() : void;
   }
}

