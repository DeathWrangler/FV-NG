package Engine.Interfaces
{
   import flash.text.TextFormat;
   
   public interface IFontMapper
   {
      
      function setLanguageCode(param1:String) : void;
      
      function getFontsToRegister() : Array;
      
      function mapFontName(param1:String, param2:String) : String;
      
      function mapFontSize(param1:String, param2:String, param3:int) : int;
      
      function mapFontEmbed(param1:String, param2:String, param3:Boolean) : Boolean;
      
      function mapFontBold(param1:String, param2:String, param3:int, param4:Boolean) : Boolean;
      
      function mapTextFormat(param1:String, param2:TextFormat) : TextFormat;
   }
}

