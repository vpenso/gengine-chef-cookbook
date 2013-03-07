
# Complex Values

↪ `recipes/config_complex_values.rb`  
↪ `attributes/config_complex_values.rb` 

## Basics

To do.

## Configuration

Overwrite the default resources or define additional resources with the Chef attribute `node.gengine.complex_values`, e.g.:

    "gengine" => {
      ...SNIP...
      "complex_values" => {
        "tmpmounted" => "tmpmounted INT >= YES NO 0 0",
        ...SNIP...
      }
      ...SNIP...
    } 

Verify the configuration of Grid Engine complex values with the command `qconf -sc`. Read the **manual "complex"** for more details. Define a file `complex_values` in the configuration repository like:

    #name               shortcut      type        relop requestable consumable default  urgency 
    #------------------------------------------------------------------------------------------
    lustre              lustre        INT         >=    YES         NO         0        0
    ...SNIP...

