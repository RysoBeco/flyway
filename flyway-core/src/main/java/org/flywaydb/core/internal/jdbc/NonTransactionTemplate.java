/*
 * Copyright 2010-2019 Boxfuse GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.flywaydb.core.internal.jdbc;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.concurrent.Callable;
import org.flywaydb.core.api.FlywayException;
import org.flywaydb.core.api.logging.Log;
import org.flywaydb.core.api.logging.LogFactory;
import org.flywaydb.core.internal.exception.FlywaySqlException;

/**
 * Spring-like template for executing transactions.
 */
public class NonTransactionTemplate implements  Template{
    private static final Log LOG = LogFactory.getLog(NonTransactionTemplate.class);

    /**
     * The connection for the transaction.
     */
    private final Connection connection;



    /**
     * Creates a new transaction template for this connection.
     *
     * @param connection          The connection for the transaction.
     */
    public NonTransactionTemplate(Connection connection) {
        this.connection = connection;
    }

    /**
     * Executes this callback within a transaction.
     *
     * @param callback The callback to execute.
     * @return The result of the transaction code.
     */
    public <T> T execute(Callable<T> callback) {
        boolean oldAutocommit = true;
        try {
            oldAutocommit = connection.getAutoCommit();
            connection.setAutoCommit(true);
            T result = callback.call();
            connection.commit();
            return result;
        } catch (Exception e) {
            RuntimeException rethrow;
            if (e instanceof SQLException) {
                rethrow = new FlywaySqlException("Unable to commit transaction", (SQLException) e);
            } else if (e instanceof RuntimeException) {
                rethrow = (RuntimeException) e;
            } else {
                rethrow = new FlywayException(e);
            }

            throw rethrow;
        } finally {
            try {
                connection.setAutoCommit(oldAutocommit);
            } catch (SQLException e) {
                LOG.error("Unable to restore autocommit to original value for connection", e);
            }
        }
    }
}