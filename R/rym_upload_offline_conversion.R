rym_upload_offline_conversion <-
  function(counter,
           data,
           client.id.type = c("CLIENT_ID", "USER_ID"),
           comment = paste0("Upload by rym at ", Sys.time()),
           login = getOption("rym.user"),
           token.path = getOption("rym.token_path")) {

    # check path
    if (is.null(token.path)) {
      token.path <- getwd()
    }

    # encode comment
    comment <- URLencode(comment)

    # make temp file
    tf <- tempfile(fileext = ".csv")

    # save temp csv
    write.csv(data, tf)

    # match arg
    client.id.type <- match.arg(client.id.type)

    # auth
    ym_token <- rym_auth(login = login, token.path = token.path)$access_token

    answer <- POST(str_glue("https://api-metrika.yandex.ru/management/v1/counter/{counter}/offline_conversions/upload?client_id_type={client.id.type}&comment={comment}"),
      body = list(file = upload_file(tf)),
      add_headers(Authorization = paste0("OAuth ", ym_token))
    )

    # remove file
    file.remove(tf)

    # check answer status
    stop_for_status(answer)

    # get answer
    raw_data <- content(answer, as = "parsed")

    # check for error
    if (!is.null(raw_data$errors)) {
      stop(raw_data$errors$error_type, ": ", raw_data$errors$message)
    }

    cat(
      " Upload Information:\n",
      "Uploadind ID:\t\t", raw_data$uploading$id, "\n",
      "Source Quantity:\t", raw_data$uploading$source_quantity, "\n",
      "Status:\t\t", raw_data$uploading$status, "\n"
    )

    return(TRUE)
  }
