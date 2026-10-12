package Classes
{
   public class PriceFormulaSettings
   {
      
      private var priceTests:Object = {};
      
      public function PriceFormulaSettings(resultObj:Object)
      {
         super();
         this.priceTests = resultObj;
      }
      
      public function getSettingsForTest(testName:String) : Object
      {
         var result:Object = null;
         if(this.priceTests.hasOwnProperty(testName))
         {
            result = this.priceTests[testName];
         }
         return result;
      }
      
      public function getMultipleForTest(testName:String) : Number
      {
         var result:Number = 0;
         var settings:Object = this.getSettingsForTest(testName);
         var scheme:Object = settings["scheme"];
         if(Boolean(scheme) && scheme.hasOwnProperty("multiple"))
         {
            result = Number(scheme["multiple"]);
         }
         return result;
      }
      
      public function getCapForTest(testName:String) : Number
      {
         var result:Number = 0;
         var settings:Object = this.getSettingsForTest(testName);
         var scheme:Object = settings["scheme"];
         if(Boolean(scheme) && scheme.hasOwnProperty("cap"))
         {
            result = Number(scheme["cap"]);
         }
         return result;
      }
      
      public function getTypeForTest(testName:String) : String
      {
         var result:String = "";
         var settings:Object = this.getSettingsForTest(testName);
         if(Boolean(settings) && settings.hasOwnProperty("type"))
         {
            result = settings["type"];
         }
         return result;
      }
   }
}

